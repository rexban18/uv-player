import 'dart:async';
import 'package:audio_service/audio_service.dart';
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

class UVAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
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
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    _player.durationStream.listen((duration) {
      if (duration != null && _currentIndex >= 0 && _currentIndex < _playlist.length) {
        final item = _playlist[_currentIndex];
        mediaItem.add(MediaItem(
          id: item.id,
          title: item.title,
          artist: item.artist,
          album: item.album,
          duration: duration,
        ));
      }
    });

    _player.positionStream.listen((position) {
      if (_currentIndex >= 0 && _currentIndex < _playlist.length) {
        final item = _playlist[_currentIndex];
        mediaItem.add(MediaItem(
          id: item.id,
          title: item.title,
          artist: item.artist,
          album: item.album,
          duration: _player.duration ?? Duration.zero,
        ));
      }
    });
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: _currentIndex,
    );
  }

  Future<void> loadPlaylist(List<MediaItemData> songs, {int startIndex = 0}) async {
    _playlist.clear();
    _playlist.addAll(songs);
    _currentIndex = startIndex;

    final mediaItems = songs.map((s) => MediaItem(
      id: s.id,
      title: s.title,
      artist: s.artist,
      album: s.album,
      duration: s.duration,
    )).toList();

    queue.add(mediaItems);

    if (songs.isNotEmpty && startIndex >= 0 && startIndex < songs.length) {
      await _playSong(songs[startIndex]);
    }
  }

  Future<void> _playSong(MediaItemData song) async {
    try {
      await _player.setFilePath(song.filePath);
      mediaItem.add(MediaItem(
        id: song.id,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
      ));
      await _player.play();
    } catch (e) {
      // Handle error
    }
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (_playlist.isEmpty) return;
    if (_isShuffle) {
      _currentIndex = (DateTime.now().millisecondsSinceEpoch % _playlist.length);
    } else {
      _currentIndex = (_currentIndex + 1) % _playlist.length;
    }
    await _playSong(_playlist[_currentIndex]);
  }

  @override
  Future<void> skipToPrevious() async {
    if (_playlist.isEmpty) return;
    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else {
      _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
      await _playSong(_playlist[_currentIndex]);
    }
  }

  @override
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
