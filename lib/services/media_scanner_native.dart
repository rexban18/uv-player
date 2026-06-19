import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/song.dart';
import '../models/video.dart';

const _uuid = Uuid();

Future<List<Song>> scanAudioFilesNative() async {
  final songs = <Song>[];
  final directories = await _getAudioDirectories();

  for (final dir in directories) {
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && _isAudioFile(entity.path)) {
          final song = await _createSongFromFile(entity);
          if (song != null) songs.add(song);
        }
      }
    }
  }

  final uniqueSongs = <String, Song>{};
  for (final song in songs) {
    uniqueSongs[song.filePath] = song;
  }
  return uniqueSongs.values.toList();
}

Future<List<Video>> scanVideoFilesNative() async {
  final videos = <Video>[];
  final directories = await _getVideoDirectories();

  for (final dir in directories) {
    if (await dir.exists()) {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && _isVideoFile(entity.path)) {
          final video = await _createVideoFromFile(entity);
          if (video != null) videos.add(video);
        }
      }
    }
  }

  final uniqueVideos = <String, Video>{};
  for (final video in videos) {
    uniqueVideos[video.filePath] = video;
  }
  return uniqueVideos.values.toList();
}

Future<List<Directory>> _getAudioDirectories() async {
  final dirs = <Directory>[];
  if (Platform.isAndroid) {
    dirs.addAll([
      Directory('/storage/emulated/0/Music'),
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Audio'),
      Directory('/storage/emulated/0/Telegram/Telegram Audio'),
    ]);
  } else if (Platform.isIOS) {
    final appDir = await getApplicationDocumentsDirectory();
    dirs.add(appDir);
  }
  return dirs;
}

Future<List<Directory>> _getVideoDirectories() async {
  final dirs = <Directory>[];
  if (Platform.isAndroid) {
    dirs.addAll([
      Directory('/storage/emulated/0/Movies'),
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/DCIM'),
      Directory('/storage/emulated/0/WhatsApp/Media/WhatsApp Video'),
      Directory('/storage/emulated/0/Telegram/Telegram Video'),
    ]);
  } else if (Platform.isIOS) {
    final appDir = await getApplicationDocumentsDirectory();
    dirs.add(appDir);
  }
  return dirs;
}

bool _isAudioFile(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['mp3', 'aac', 'wav', 'flac', 'ogg', 'm4a', 'wma', 'opus'].contains(ext);
}

bool _isVideoFile(String path) {
  final ext = path.split('.').last.toLowerCase();
  return ['mp4', 'mkv', 'avi', 'mov', 'flv', 'webm', 'ts', 'wmv', '3gp'].contains(ext);
}

Future<Song?> _createSongFromFile(File file) async {
  try {
    final fileName = file.path.split('/').last;
    final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

    String title = nameWithoutExt;
    String artist = 'Unknown Artist';
    if (nameWithoutExt.contains(' - ')) {
      final parts = nameWithoutExt.split(' - ');
      artist = parts[0].trim();
      title = parts.sublist(1).join(' - ').trim();
    }

    final stat = await file.stat();

    return Song(
      id: _uuid.v5(Uuid.NAMESPACE_URL, file.path),
      title: title,
      artist: artist,
      album: 'Unknown Album',
      artUri: '',
      filePath: file.path,
      durationMs: stat.modified.millisecondsSinceEpoch,
      isFavorite: false,
    );
  } catch (e) {
    return null;
  }
}

Future<Video?> _createVideoFromFile(File file) async {
  try {
    final fileName = file.path.split('/').last;
    final nameWithoutExt = fileName.replaceAll(RegExp(r'\.[^.]+$'), '');

    final stat = await file.stat();

    return Video(
      id: _uuid.v5(Uuid.NAMESPACE_URL, file.path),
      title: nameWithoutExt,
      filePath: file.path,
      durationMs: stat.modified.millisecondsSinceEpoch,
      thumbnailPath: '',
      width: 0,
      height: 0,
    );
  } catch (e) {
    return null;
  }
}
