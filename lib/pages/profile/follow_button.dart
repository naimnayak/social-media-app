import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FollowButton extends StatefulWidget {
  final String? uid;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const FollowButton({
    super.key,
    required this.uid,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  _FollowButtonState createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          final userUid = widget.uid ?? currentUser.uid;
          final followingRef = FirebaseFirestore.instance
              .collection('following')
              .doc(currentUser.uid)
              .collection('userFollowing')
              .doc(userUid);

          if (widget.isFollowing) {
            await followingRef.delete(); // Unfollow
          } else {
            await followingRef.set({}); // Follow (empty map is fine here)
          }

          widget.onFollowToggle(); // Notify parent to refresh follow status
        }
      },
      child: Text(widget.isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
