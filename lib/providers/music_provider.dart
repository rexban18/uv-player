import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:just_audio/just_audio.dart';
import 'dart:convert';
import '../models/song.dart';
import '../main.dart';
import '../services/audio_handler.dart';
import '../services/media_scanner.dart';

class MusicProvider extends ChangeNotifier {
  List<Song> _songs = [];
  List<Song> _favorites = [];
  bool _isLoading = false;
  String _searchQuery = '';

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
  Song? get currentSong {
    final handler = audioHandler;
    if (handler == null) return null;
    return handler.currentSong != null
        ? _findSongById(handler.currentSong!.id)
        : null;
  }

  bool get isPlaying => audioHandler?.isPlaying ?? false;
  bool get isShuffle => audioHandler?.isShuffle ?? false;
  LoopMode get repeatMode => audioHandler?.repeatMode ?? LoopMode.off;

  Stream<bool> get playingStream =>
      audioHandler?.playingStream ?? Stream.value(false);
  Stream<Duration> get positionStream =>
      audioHandler?.positionStream ?? Stream.value(Duration.zero);
  Stream<Duration?> get durationStream =>
      audioHandler?.durationStream ?? Stream.value(null);

  Song? _findSongById(String id) {
    try {
      return _songs.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

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
    final handler = audioHandler;
    if (handler == null) return;

    final mediaItems = _songs.map((s) => MediaItemData(
      id: s.id,
      title: s.title,
      artist: s.artist,
      album: s.album,
      artUri: s.artUri,
      filePath: s.filePath,
      duration: s.duration,
    )).toList();

    final index = _songs.indexWhere((s) => s.id == song.id);
    await handler.loadPlaylist(mediaItems, startIndex: index >= 0 ? index : 0);
    notifyListeners();
  }

  Future<void> playFromFavorites(Song song) async {
    final handler = audioHandler;
    if (handler == null) return;

    final mediaItems = _favorites.map((s) => MediaItemData(
      id: s.id,
      title: s.title,
      artist: s.artist,
      album: s.album,
      artUri: s.artUri,
      filePath: s.filePath,
      duration: s.duration,
    )).toList();

    final index = _favorites.indexWhere((s) => s.id == song.id);
    await handler.loadPlaylist(mediaItems, startIndex: index >= 0 ? index : 0);
    notifyListeners();
  }

  Future<void> togglePlay() async {
    final handler = audioHandler;
    if (handler == null) return;

    if (isPlaying) {
      await handler.pause();
    } else {
      await handler.play();
    }
    notifyListeners();
  }

  Future<void> next() async {
    final handler = audioHandler;
    if (handler == null) return;
    await handler.skipToNext();
    notifyListeners();
  }

  Future<void> previous() async {
    final handler = audioHandler;
    if (handler == null) return;
    await handler.skipToPrevious();
    notifyListeners();
  }

  void toggleShuffle() {
    audioHandler?.toggleShuffle();
    notifyListeners();
  }

  void toggleRepeat() {
    audioHandler?.toggleRepeat();
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await audioHandler?.seek(position);
  }

  Future<void> setVolume(double volume) async {
    await audioHandler?.setVolume(volume);
  }

  Future<void> refresh() async {
    await loadSongs();
  }
}
