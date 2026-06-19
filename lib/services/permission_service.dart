import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAudioPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.audio.status;
    if (status.isGranted) return true;

    final result = await Permission.audio.request();
    if (result.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  static Future<bool> requestVideoPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.videos.status;
    if (status.isGranted) return true;

    final result = await Permission.videos.request();
    if (result.isGranted) return true;

    final storageStatus = await Permission.storage.request();
    return storageStatus.isGranted;
  }

  static Future<bool> requestAllPermissions() async {
    final audio = await requestAudioPermission();
    final video = await requestVideoPermission();
    return audio && video;
  }

  static Future<bool> hasAudioPermission() async {
    if (kIsWeb) return true;
    return await Permission.audio.isGranted ||
        await Permission.storage.isGranted;
  }

  static Future<bool> hasVideoPermission() async {
    if (kIsWeb) return true;
    return await Permission.videos.isGranted ||
        await Permission.storage.isGranted;
  }
}
