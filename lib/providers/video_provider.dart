import 'package:flutter/material.dart';
import '../models/video.dart';
import '../services/media_scanner.dart';

class VideoProvider extends ChangeNotifier {
  List<Video> _videos = [];
  bool _isLoading = false;
  String _searchQuery = '';

  List<Video> get videos {
    if (_searchQuery.isEmpty) return _videos;
    return _videos
        .where((v) => v.title.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Video> get allVideos => _videos;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadVideos() async {
    _isLoading = true;
    notifyListeners();

    _videos = await MediaScanner.scanVideoFiles();

    _isLoading = false;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadVideos();
  }
}
