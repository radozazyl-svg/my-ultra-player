import 'package:flutter/material.dart';
import '../models/video_model.dart';
import '../services/database_service.dart';
import '../services/video_scanner.dart';

class VideoProvider with ChangeNotifier {
  List<VideoModel> _videos = [];
  List<VideoModel> _filteredVideos = [];
  bool _isLoading = false;
  final DatabaseService _dbService = DatabaseService();

  List<VideoModel> get videos => _filteredVideos.isEmpty && _searchQuery.isEmpty ? _videos : _filteredVideos;
  bool get isLoading => _isLoading;
  String _searchQuery = "";

  Future<void> loadVideos() async {
    _isLoading = true;
    notifyListeners();

    // 1. تحميل من قاعدة البيانات أولاً
    _videos = await _dbService.getVideos();
    
    // 2. إذا كانت قاعدة البيانات فارغة، نقوم بالفحص
    if (_videos.isEmpty) {
      _videos = await VideoScanner.scanVideos();
      for (var video in _videos) {
        await _dbService.insertVideo(video);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  void searchVideos(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      _filteredVideos = [];
    } else {
      _filteredVideos = _videos
          .where((v) => v.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  void sortVideos(String criteria) {
    switch (criteria) {
      case 'name':
        _videos.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'size':
        _videos.sort((a, b) => a.size.compareTo(b.size));
        break;
      case 'date':
        _videos.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case 'duration':
        _videos.sort((a, b) => b.duration.compareTo(a.duration));
        break;
    }
    notifyListeners();
  }

  Future<void> toggleFavorite(VideoModel video) async {
    video.isFavorite = !video.isFavorite;
    await _dbService.updateVideo(video);
    notifyListeners();
  }

  Future<void> updateLastPosition(VideoModel video, Duration position) async {
    video.lastPosition = position;
    await _dbService.updateVideo(video);
    notifyListeners();
  }
}
