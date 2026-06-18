import 'dart:async';
import 'package:just_audio/just_audio.dart';
import '../models/song.dart';

class AudioPlayerService {
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal();

  final AudioPlayer _player = AudioPlayer();
  List<Song> _playlist = [];
  int _currentIndex = -1;
  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;

  AudioPlayer get player => _player;
  List<Song> get playlist => _playlist;
  int get currentIndex => _currentIndex;
  Song? get currentSong => _currentIndex >= 0 && _currentIndex < _playlist.length
      ? _playlist[_currentIndex]
      : null;
  bool get isPlaying => _player.playing;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;

  Stream<bool> get playingStream => _player.playingStream;
  Stream<Duration> get positionStream => _player.positionStream;
  Stream<Duration?> get durationStream => _player.durationStream;
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Future<void> playSong(Song song, {List<Song>? playlist, int? index}) async {
    if (playlist != null) {
      _playlist = List.from(playlist);
      _currentIndex = index ?? _playlist.indexOf(song);
    } else {
      _currentIndex = _playlist.indexOf(song);
      if (_currentIndex == -1) {
        _playlist.add(song);
        _currentIndex = _playlist.length - 1;
      }
    }

    try {
      await _player.setFilePath(song.filePath);
      await _player.play();
    } catch (e) {
      // Handle playback error
    }
  }

  Future<void> play() async => await _player.play();
  Future<void> pause() async => await _player.pause();
  Future<void> togglePlay() async {
    if (_player.playing) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> seek(Duration position) async => await _player.seek(position);

  Future<void> seekForward([Duration offset = const Duration(seconds: 10)]) async {
    final newPos = _player.position + offset;
    final duration = _player.duration ?? Duration.zero;
    await _player.seek(newPos > duration ? duration : newPos);
  }

  Future<void> seekBackward([Duration offset = const Duration(seconds: 10)]) async {
    final newPos = _player.position - offset;
    await _player.seek(newPos < Duration.zero ? Duration.zero : newPos);
  }

  Future<void> next() async {
    if (_playlist.isEmpty) return;

    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }

    await playSong(_playlist[_currentIndex]);
  }

  Future<void> previous() async {
    if (_playlist.isEmpty) return;

    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await playSong(_playlist[_currentIndex]);
    }
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
  }

  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _player.setLoopMode(_repeatMode == RepeatMode.off
        ? LoopMode.off
        : _repeatMode == RepeatMode.one
            ? LoopMode.one
            : LoopMode.all);
  }

  Future<void> setVolume(double volume) async => await _player.setVolume(volume);

  Future<void> setSpeed(double speed) async => await _player.setSpeed(speed);

  Future<void> stop() async {
    await _player.stop();
    _currentIndex = -1;
  }

  void dispose() {
    _player.dispose();
  }
}

enum RepeatMode { off, all, one }
