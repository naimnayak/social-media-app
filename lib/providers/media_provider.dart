import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MediaProvider with ChangeNotifier {
  bool _isLoading = false;
  List<String> _videoUrls = [];
  List<String> get videoUrls => _videoUrls;

  set videoUrls(List<String> urls) {
    _videoUrls = urls;
    notifyListeners();
    _cacheVideoUrls();
  }

  bool get isLoading => _isLoading;

  MediaProvider() {
    _loadFromCache();
  }

  Future<void> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedUrls = prefs.getStringList('videoUrls') ?? [];
    _videoUrls = cachedUrls;
    notifyListeners();
  }

  Future<void> _cacheVideoUrls() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('videoUrls', _videoUrls);
  }

  Future<void> fetchVideos() async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Simulate fetching video URLs
      await Future.delayed(const Duration(seconds: 2));

      // Example URLs
      final newUrls = [
        'https://example.com/video1',
        'https://example.com/video2',
      ];

      videoUrls = newUrls; // Use setter to update

    } catch (e) {
      // Handle errors if necessary
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
