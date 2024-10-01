import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ganpatibapa/pages/video_upload_screen.dart';
import 'package:ganpatibapa/pages/navigation/navigation.dart'; // Import NavigationService

class VideoFeedScreen extends StatefulWidget {
  const VideoFeedScreen({super.key});

  @override
  _VideoFeedScreenState createState() => _VideoFeedScreenState();
}

class _VideoFeedScreenState extends State<VideoFeedScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _mediaData = [];
  String? currentUserId;
  StreamSubscription<User?>? _authStateChangesSubscription;

  @override
  void initState() {
    super.initState();
    _initializeUserAndFetchMedia();
  }

  @override
  void dispose() {
    _authStateChangesSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeUserAndFetchMedia() async {
    _authStateChangesSubscription = FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (mounted) {
          NavigationService.instance.replaceWith('/login');
        }
      } else {
        currentUserId = user.uid;

        SharedPreferences prefs = await SharedPreferences.getInstance();
        bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

        if (!isLoggedIn) {
          if (mounted) {
            NavigationService.instance.replaceWith('/login');
          }
        } else {
          await _fetchMediaAndUserData(user.uid);
        }
      }
    });
  }

  Future<void> _fetchMediaAndUserData(String uid) async {
    try {
      setState(() {
        _isLoading = true;
      });

      QuerySnapshot followingSnapshot = await FirebaseFirestore.instance
          .collection('following')
          .doc(currentUserId)
          .collection('userFollowing')
          .get();
      List<String> followingUserIds = followingSnapshot.docs.map((doc) => doc.id).toList();
      followingUserIds.add(currentUserId!);

      QuerySnapshot mediaSnapshot = await FirebaseFirestore.instance
          .collection('media')
          .where('userId', whereIn: followingUserIds)
          .get();

      _mediaData = [];
      for (var mediaDoc in mediaSnapshot.docs) {
        String userId = mediaDoc['userId'];
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        _mediaData.add({
          'media': mediaDoc.data() as Map<String, dynamic>,
          'username': userDoc['username'] ?? 'Unknown User',
        });
      }

      setState(() {
        _isLoading = false;
      });
    } on FirebaseException catch (e) {
      print('Error fetching media: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void refreshFeed() {
    _initializeUserAndFetchMedia();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Bappa\'s Feed'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              User? user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final shouldRefresh = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaUploadScreen(uid: user.uid),
                  ),
                );
                if (shouldRefresh == true) {
                  _fetchMediaAndUserData(user.uid);
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please log in to upload media')),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);
              await FirebaseAuth.instance.signOut();
              NavigationService.instance.replaceWith('/login');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _mediaData.isEmpty
              ? const Center(child: Text("No media uploaded yet."))
              : ListView.builder(
                  itemCount: _mediaData.length,
                  itemBuilder: (context, index) {
                    final media = _mediaData[index]['media'];
                    final username = _mediaData[index]['username'];
                    bool liked = false;
                    int likes = media['likeCount'] ?? 0;
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundImage: NetworkImage(
                                        media['profilePicUrl'] ?? 'https://via.placeholder.com/150',
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    const SizedBox(width: 10),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                if (media['isVideo'])
                                  VideoPlayerWidget(videoUrl: media['url'])
                                else
                                  Image.network(media['url'], fit: BoxFit.cover),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      IconButton(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        constraints: const BoxConstraints(),
                                        onPressed: () {
                                          setState(() {
                                            liked = !liked;
                                            if (liked) {
                                              likes += 1;
                                            } else {
                                              likes -= 1;
                                            }
                                          });
                                        },
                                        icon: liked
                                            ? const Icon(Icons.favorite, color: Colors.red)
                                            : const Icon(Icons.favorite_border),
                                      ),
                                      IconButton(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                        constraints: const BoxConstraints(),
                                        onPressed: () {},
                                        icon: const Icon(Icons.bookmark_outline),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Text("$likes likes"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isPlaying = !_isPlaying;
        });
        if (_isPlaying) {
          _controller.play();
        } else {
          _controller.pause();
        }
      },
      child: SizedBox(
        height: 200,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(_controller),
            if (!_isPlaying)
              const Icon(Icons.play_arrow, color: Colors.white, size: 50),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
