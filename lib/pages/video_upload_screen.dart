
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/image_picker.dart'; // Import for ImagePickerService

class MediaUploadScreen extends StatefulWidget {
  final String uid; // Receive the uid here

  const MediaUploadScreen({super.key, required this.uid});

  @override
  _MediaUploadScreenState createState() => _MediaUploadScreenState();
}

class _MediaUploadScreenState extends State<MediaUploadScreen> {
  final ImagePickerService _pickerService = ImagePickerService();
  XFile? _mediaFile;
  final TextEditingController _captionController = TextEditingController(); // Caption controller
  bool _isUploading = false;
  bool _isVideo = false; // To track if the selected file is a video

  @override
  void dispose() {
    _captionController.dispose(); // Dispose the caption controller
    super.dispose();
  }

  Future<void> _pickVideo() async {
    XFile? video = await _pickerService.pickVideoFromGallery();
    if (video != null) {
      setState(() {
        _mediaFile = video;
        _isVideo = true;
      });
    }
  }

  Future<void> _pickImage() async {
    XFile? image = await _pickerService.pickImageFromGallery();
    if (image != null) {
      setState(() {
        _mediaFile = image;
        _isVideo = false;
      });
    }
  }

  Future<void> _uploadMedia() async {
    if (_mediaFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        String filePath = _isVideo ? 'videos' : 'images';
        String fileExtension = _isVideo ? '.mp4' : '.jpg';

        Reference ref = FirebaseStorage.instance
            .ref()
            .child('$filePath/${DateTime.now().millisecondsSinceEpoch}$fileExtension');

        UploadTask uploadTask = ref.putData(await _mediaFile!.readAsBytes());

        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();

        // Store media information in Firestore (with caption)
        DocumentReference mediaRef = await FirebaseFirestore.instance.collection('media').add({
          'url': downloadURL,
          'timestamp': DateTime.now(),
          'userId': widget.uid,
          'caption': _captionController.text,
          'isVideo': _isVideo,
        });

        // Automatically create the "comments" subcollection
        await mediaRef.collection('comments').add({});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Media uploaded successfully!')),
        );

        // Navigate back to MediaFeedScreen and trigger refresh
        Navigator.of(context).pop(true);
      } on FirebaseException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading media: $e')),
        );
      } finally {
        setState(() {
          _isUploading = false;
          _mediaFile = null;
          _captionController.clear(); // Clear the caption field after upload
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Media')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickVideo,
              child: const Text('Select Video'),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            if (_mediaFile != null) ...[
              Text(_mediaFile!.name),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _captionController,
                  decoration: const InputDecoration(labelText: 'Caption'),
                ),
              ),

              ElevatedButton(
                onPressed: _isUploading ? null : _uploadMedia,
                child: _isUploading
                    ? const CircularProgressIndicator()
                    : const Text('Upload Media'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
