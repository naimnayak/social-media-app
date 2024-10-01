import 'dart:io'; // Import for File handling
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganpatibapa/authentication/login_screen.dart';
import 'package:ganpatibapa/services/firebase_auth_service.dart';
import 'package:ganpatibapa/pages/user_profile.dart';
import 'package:ganpatibapa/pages/profile/follow_button.dart';
import 'package:ganpatibapa/pages/profile/media_grid_section.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganpatibapa/services/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  final String? uid;
  final VoidCallback? onRefresh;

  const ProfileScreen({super.key, this.uid, this.onRefresh});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserProfile? _userProfile;
  bool _isLoading = true;
  bool isFollowing = false;
  final ImagePickerService _imagePickerService = ImagePickerService(); // Instance for image picking

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final userUid = widget.uid ?? currentUser?.uid;

      if (userUid != null) {
        UserProfile? userProfile = await _authService.getUserProfile(userUid);
        setState(() {
          _userProfile = userProfile;
          _isLoading = false;
        });
        if (currentUser != null) {
          _checkFollowingStatus(userUid);
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> _checkFollowingStatus(String userUid) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      final followingRef = FirebaseFirestore.instance
          .collection('following')
          .doc(currentUser.uid)
          .collection('userFollowing')
          .doc(userUid);

      final followingSnapshot = await followingRef.get();
      setState(() {
        isFollowing = followingSnapshot.exists;
      });
    }
  }

  Future<void> _uploadProfilePhoto() async {
    final XFile? image = await _imagePickerService.pickImageFromGallery();
    if (image != null) {
      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_photos')
            .child('${currentUser?.uid}.jpg');

        final uploadTask = storageRef.putFile(File(image.path));
        await uploadTask.whenComplete(() async {
          final downloadUrl = await storageRef.getDownloadURL();
          await _authService.updateUserProfilePhoto(currentUser!.uid, downloadUrl);
          _loadProfile(); // Refresh profile data after upload
        });
      } catch (e) {
        print('Error uploading profile photo: $e');
      }
    }
  }

  Future<String?> _getCurrentUserUid() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: _getCurrentUserUid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final currentUserUid = snapshot.data;

          return Scaffold(
            backgroundColor: const Color.fromARGB(255, 0, 2, 51),
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 0, 2, 51),
              title: const Text('Profile', style: TextStyle(color: Colors.white)),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () async {
                    try {
                      await _authService.signOut();
                      SharedPreferences prefs = await SharedPreferences.getInstance();
                      await prefs.setBool('isLoggedIn', false);

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (Route<dynamic> route) => false,
                      );
                    } catch (e) {
                      print('Error signing out: $e');
                    }
                  },
                ),
              ],
            ),
            body: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : (_userProfile != null
                    ? Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      _userProfile?.profilePhotoUrl ??
                                          'https://via.placeholder.com/150',
                                    ),
                                    backgroundColor: Colors.transparent,
                                  ),
                                  if (widget.uid == currentUserUid)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: IconButton(
                                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                                        onPressed: _uploadProfilePhoto, // Call upload method
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: Text(
                                _userProfile?.username ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            if (widget.uid != null && widget.uid != currentUserUid)
                              Center(
                                child: FollowButton(
                                  uid: widget.uid!,
                                  isFollowing: isFollowing,
                                  onFollowToggle: _loadProfile,
                                ),
                              ),
                            const SizedBox(height: 20),
                            Expanded(
                              child: MediaGrid(uid: widget.uid ?? currentUserUid!),
                            ),
                          ],
                        ),
                      )
                    : const Center(child: Text('User not found'))),
          );
        }
      },
    );
  }
}
