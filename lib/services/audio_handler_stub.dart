import 'dart:async';
import 'package:just_audio/just_audio.dart';

class MediaItemData {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artUri;
  final String filePath;
  final Duration duration;

  MediaItemData({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artUri,
    required this.filePath,
    required this.duration,
  });
}

class UVAudioHandler {
  final AudioPlayer _player = AudioPlayer();
  final List<MediaItemData> _playlist = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  LoopMode _repeatMode = LoopMode.off;

  AudioPlayer get player => _player;
  List<MediaItemData> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  LoopMode get repeatMode => _repeatMode;

  UVAudioHandler() {
    _init();
  }

  void _init() {
    _player.durationStream.listen((duration) {
      if (duration != null && _currentIndex >= 0 && _currentIndex < _playlist.length) {}
    });
  }

  Future<void> loadPlaylist(List<MediaItemData> songs, {int startIndex = 0}) async {
    _playlist.clear();
    _playlist.addAll(songs);
    _currentIndex = startIndex;

    if (songs.isNotEmpty && startIndex >= 0 && startIndex < songs.length) {
      await _playSong(songs[startIndex]);
    }
  }

  Future<void> _playSong(MediaItemData song) async {
    try {
      if (song.filePath.startsWith('http') || song.filePath.startsWith('https')) {
        await _player.setUrl(song.filePath);
      } else {
        await _player.setFilePath(song.filePath);
      }
      await _player.play();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> play() => _player.play();
  Future<void> pause() => _player.pause();
  Future<void> stop() async => await _player.stop();
  Future<void> seek(Duration position) => _player.seek(position);

  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;
    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSong(_playlist[_currentIndex]);
  }

  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _playSong(_playlist[_currentIndex]);
    }
  }

  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= _playlist.length) return;
    _currentIndex = index;
    await _playSong(_playlist[_currentIndex]);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    _player.setShuffleModeEnabled(_isShuffle);
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case LoopMode.off:
        _repeatMode = LoopMode.all;
        break;
      case LoopMode.all:
        _repeatMode = LoopMode.one;
        break;
      case LoopMode.one:
        _repeatMode = LoopMode.off;
        break;
    }
    _player.setLoopMode(_repeatMode);
  }

  Future<void> setVolume(double volume) => _player.setVolume(volume * 100);
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);

  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<bool> get playingStream => _player.playingStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  MediaItemData? get currentSong =>
      _currentIndex >= 0 && _currentIndex < _playlist.length
          ? _playlist[_currentIndex]
          : null;

  bool get isPlaying => _player.playing;
}
