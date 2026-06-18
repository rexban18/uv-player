import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/playlist.dart';
import '../models/song.dart';

class PlaylistProvider extends ChangeNotifier {
  List<Playlist> _playlists = [];
  static const _uuid = Uuid();

  List<Playlist> get playlists => _playlists;

  Future<void> loadPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('playlists') ?? [];
      _playlists = data.map((e) {
        try {
          return Playlist.fromJson(jsonDecode(e) as Map<String, dynamic>);
        } catch (_) {
          return Playlist(id: '', name: '');
        }
      }).where((p) => p.id.isNotEmpty).toList();
    } catch (e) {
      _playlists = [];
    }
    notifyListeners();
  }

  Future<void> _savePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = _playlists.map((p) => jsonEncode(p.toJson())).toList();
      await prefs.setStringList('playlists', data);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: _uuid.v4(),
      name: name,
    );
    _playlists.add(playlist);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> deletePlaylist(String id) async {
    _playlists.removeWhere((p) => p.id == id);
    await _savePlaylists();
    notifyListeners();
  }

  Future<void> renamePlaylist(String id, String newName) async {
    final index = _playlists.indexWhere((p) => p.id == id);
    if (index != -1) {
      _playlists[index].name = newName;
      await _savePlaylists();
      notifyListeners();
    }
  }

  Future<void> addSongToPlaylist(String playlistId, Song song) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      if (!_playlists[index].songIds.contains(song.id)) {
        _playlists[index].songIds.add(song.id);
        await _savePlaylists();
        notifyListeners();
      }
    }
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    final index = _playlists.indexWhere((p) => p.id == playlistId);
    if (index != -1) {
      _playlists[index].songIds.remove(songId);
      await _savePlaylists();
      notifyListeners();
    }
  }

  Playlist? getPlaylist(String id) {
    try {
      return _playlists.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Song> getPlaylistSongs(String playlistId, List<Song> allSongs) {
    final playlist = getPlaylist(playlistId);
    if (playlist == null) return [];

    return playlist.songIds
        .map((id) => allSongs.firstWhere(
              (s) => s.id == id,
              orElse: () => Song(
                  id: '',
                  title: 'Unknown',
                  artist: '',
                  album: '',
                  artUri: '',
                  filePath: '',
                  durationMs: 0),
            ))
        .where((s) => s.id.isNotEmpty)
        .toList();
  }
}
