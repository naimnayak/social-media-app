import 'package:flutter/material.dart';
import 'package:ganpatibapa/pages/user_profile.dart';

class UserProfileSection extends StatelessWidget {
  final UserProfile? userProfile;
  final bool isCurrentUser;
  final bool isFollowing;
  final VoidCallback onFollowToggle;

  const UserProfileSection({
    super.key,
    required this.userProfile,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.onFollowToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 50,
          backgroundImage: NetworkImage(
            userProfile?.profilePhotoUrl ?? 'https://via.placeholder.com/150',
          ),
          backgroundColor: Colors.transparent,
        ),
        if (isCurrentUser)
          IconButton(
            icon: const Icon(Icons.camera_alt, color: Colors.white),
            onPressed: () {
              // Logic to upload a profile photo
            },
          ),
        Text(
          userProfile?.username ?? 'Unknown User',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        if (!isCurrentUser)
          ElevatedButton(
            onPressed: onFollowToggle,
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
          ),
      ],
    );
  }
}
