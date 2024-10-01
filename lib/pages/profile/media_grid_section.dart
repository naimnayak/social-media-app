// pages/widgets/media_grid.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:ganpatibapa/pages/profile/video_player_screen.dart'; // Import VideoPlayerScreen
import 'package:ganpatibapa/pages/profile/image_preview_screen.dart'; // Import ImagePreviewScreen

class MediaGrid extends StatelessWidget {
  final String? uid;

  const MediaGrid({super.key, this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('media') // Updated collection name
          .where('userId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final media = snapshot.data?.docs ?? [];

        if (media.isEmpty) {
          return const Center(child: Text('No posts found'));
        }

        return MasonryGridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          itemCount: media.length,
          itemBuilder: (context, index) {
            final mediaDoc = media[index];
            final mediaData = mediaDoc.data() as Map<String, dynamic>?;

            final mediaUrl = mediaData?['url'] ?? '';
            final isVideo = mediaData?['isVideo'] ?? false;

            if (isVideo) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPlayerScreen(videoUrl: mediaUrl),
                    ),
                  );
                },
                child: Container(
                  color: Colors.grey, // Video placeholder
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              );
            } else {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImagePreviewScreen(imageUrl: mediaUrl),
                    ),
                  );
                },
                child: Image.network(
                  mediaUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Icon(Icons.error, color: Colors.red));
                  },
                ),
              );
            }
          },
        );
      },
    );
  }
}
