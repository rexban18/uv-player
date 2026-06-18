import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/song.dart';
import '../services/audio_player_service.dart';
import '../services/media_scanner.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> _favorites = [];
  bool _isLoading = false;
  String _searchQuery = '';
  final AudioPlayerService _audioService = AudioPlayerService();

  List<Song> get songs {
    if (_searchQuery.isEmpty) return _songs;
    return _songs
        .where((s) =>
            s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            s.artist.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  List<Song> get allSongs => _songs;
  List<Song> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  AudioPlayerService get audioService => _audioService;
  Song? get currentSong => _audioService.currentSong;
  bool get isPlaying => _audioService.isPlaying;

  Stream<bool> get playingStream => _audioService.playingStream;
  Stream<Duration> get positionStream => _audioService.positionStream;
  Stream<Duration?> get durationStream => _audioService.durationStream;

  Future<void> loadSongs() async {
    _isLoading = true;
    notifyListeners();

    _songs = await MediaScanner.scanAudioFiles();
    await _loadFavorites();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favJson = prefs.getStringList('favorite_songs') ?? [];
      final favIds = favJson.map((e) => jsonDecode(e) as Map<String, dynamic>).toList();
      final favMap = <String, bool>{};
      for (final fav in favIds) {
        favMap[fav['id'] as String] = true;
      }
      for (final song in _songs) {
        song.isFavorite = favMap[song.id] == true;
      }
      _favorites = _songs.where((s) => s.isFavorite).toList();
    } catch (e) {
      _favorites = [];
    }
  }

  Future<void> toggleFavorite(Song song) async {
    song.isFavorite = !song.isFavorite;
    if (song.isFavorite) {
      _favorites.add(song);
    } else {
      _favorites.removeWhere((s) => s.id == song.id);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final favList = _favorites.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList('favorite_songs', favList);
    } catch (e) {
      // Handle error
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> playSong(Song song) async {
    await _audioService.playSong(song, playlist: _songs);
    notifyListeners();
  }

  Future<void> playFromFavorites(Song song) async {
    await _audioService.playSong(song, playlist: _favorites);
    notifyListeners();
  }

  Future<void> togglePlay() async {
    await _audioService.togglePlay();
    notifyListeners();
  }

  Future<void> next() async {
    await _audioService.next();
    notifyListeners();
  }

  Future<void> previous() async {
    await _audioService.previous();
    notifyListeners();
  }

  void toggleShuffle() {
    _audioService.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    _audioService.toggleRepeat();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioService.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await _audioService.setVolume(volume);
  }

  Future<void> refresh() async {
    await loadSongs();
  }
}
