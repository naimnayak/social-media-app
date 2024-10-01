import 'package:cloud_firestore/cloud_firestore.dart';

// UserProfile class
class UserProfile {
  final String uid;
  final String email;
  final String username;
  String? _profilePhotoUrl; // Private field for profile photo URL
  final String? bio; // Optional bio

  UserProfile({
    required this.uid,
    required this.email,
    required this.username,
    String? profilePhotoUrl,
    this.bio,
  }) : _profilePhotoUrl = profilePhotoUrl;

  // Convert UserProfile object to a Map (for saving to Firestore)
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'username': username,
    'profilePhotoUrl': _profilePhotoUrl,
    'bio': bio,
  };

  // Create UserProfile object from a Map (from Firestore data)
  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    uid: json['uid'],
    email: json['email'],
    username: json['username'],
    profilePhotoUrl: json['profilePhotoUrl'],
    bio: json['bio'],
  );

  // Create UserProfile object from a Firestore DocumentSnapshot
  factory UserProfile.fromDocument(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id, // Use the document ID as the UID
      email: data['email'],
      username: data['username'],
      profilePhotoUrl: data['profilePhotoUrl'],
      bio: data['bio'],
    );
  }

  // Getter for profile photo URL
  String? get profilePhotoUrl => _profilePhotoUrl;

  // Setter for profile photo URL
  set profilePhotoUrl(String? url) {
    _profilePhotoUrl = url;
  }
}

// Comment class
class Comment {
  final String text;
  final String authorUid;
  final Timestamp timestamp;

  Comment({
    required this.text,
    required this.authorUid,
    required this.timestamp,
  });

  // Convert Comment object to a Map (for saving to Firestore)
  Map<String, dynamic> toJson() => {
    'text': text,
    'authorUid': authorUid,
    'timestamp': timestamp,
  };

  // Create Comment object from a Map (from Firestore data)
  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    text: json['text'],
    authorUid: json['authorUid'],
    timestamp: json['timestamp'],
  );
}
