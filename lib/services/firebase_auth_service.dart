import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';
import 'package:ganpatibapa/pages/user_profile.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      // Fetch or create user profile after login
      UserProfile? userProfile = await FirestoreService().getUserProfile(userCredential.user!.uid);
      if (userProfile == null) {
        // If no profile exists, create one
        userProfile = UserProfile(
          uid: userCredential.user!.uid,
          email: email,
          username: 'new_user',
        );
        await FirestoreService().createOrUpdateUserProfile(userProfile);
      }

      return userCredential;
    } on FirebaseAuthException {
      return null;
    }
  }

  Future<UserCredential?> createUserWithEmailAndPassword(
      String email, String password, String username) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // After successful sign up, create a user profile
      UserProfile userProfile = UserProfile(
        uid: userCredential.user!.uid,
        email: email,
        username: username,
      );
      await FirestoreService().createOrUpdateUserProfile(userProfile);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot userSnapshot = await _firestore.collection('users').doc(uid).get();
      if (userSnapshot.exists) {
        return UserProfile.fromJson(userSnapshot.data() as Map<String, dynamic>);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<void> createOrUpdateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore.collection('users').doc(userProfile.uid).set(userProfile.toJson());
    } catch (e) {
      print('Error creating/updating user profile: $e');
    }
  }

    Future<void> updateUserProfilePhoto(String uid, String photoUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profilePhotoUrl': photoUrl,
      });
    } catch (e) {
      print('Error updating user profile photo: $e');
    }
  }
}

