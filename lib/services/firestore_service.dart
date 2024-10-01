import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ganpatibapa/pages/user_profile.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrUpdateUserProfile(UserProfile userProfile) async {
    try {
      await _firestore.collection('users').doc(userProfile.uid).set(userProfile.toJson());
    } catch (e) {
      print('Error updating user profile: $e');
    }
  }

  Future<UserProfile?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return UserProfile.fromJson(snapshot.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }

  // Other Firestore-related methods...
}
