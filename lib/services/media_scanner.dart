import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uuid/uuid.dart';
import '../models/song.dart';
import '../models/video.dart';
import 'permission_service.dart';
import 'media_scanner_native.dart'
    if (dart.library.html) 'media_scanner_stub.dart';

const _uuid = Uuid();

class MediaScanner {
  static Future<List<Song>> scanAudioFiles() async {
    if (kIsWeb) return [];

    final hasPermission = await PermissionService.hasAudioPermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestAudioPermission();
      if (!granted) return [];
    }

    try {
      return await scanAudioFilesNative();
    } catch (e) {
      return [];
    }
  }

  static Future<List<Video>> scanVideoFiles() async {
    if (kIsWeb) return [];

    final hasPermission = await PermissionService.hasVideoPermission();
    if (!hasPermission) {
      final granted = await PermissionService.requestVideoPermission();
      if (!granted) return [];
    }

    try {
      return await scanVideoFilesNative();
    } catch (e) {
      return [];
    }
  }

  static bool isAudioFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp3', 'aac', 'wav', 'flac', 'ogg', 'm4a', 'wma', 'opus'].contains(ext);
  }

  static bool isVideoFile(String path) {
    final ext = path.split('.').last.toLowerCase();
    return ['mp4', 'mkv', 'avi', 'mov', 'flv', 'webm', 'ts', 'wmv', '3gp'].contains(ext);
  }

  static String generateId(String path) {
    return _uuid.v5(Uuid.NAMESPACE_URL, path);
  }
}
