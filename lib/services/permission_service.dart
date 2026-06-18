import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAudioPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.audio.status;
      if (status.isGranted) return true;

      final result = await Permission.audio.request();
      if (result.isGranted) return true;

      // Fallback for older Android
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.mediaLibrary.status;
      if (status.isGranted) return true;
      final result = await Permission.mediaLibrary.request();
      return result.isGranted;
    }
    return false;
  }

  static Future<bool> requestVideoPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.videos.status;
      if (status.isGranted) return true;

      final result = await Permission.videos.request();
      if (result.isGranted) return true;

      // Fallback
      final storageStatus = await Permission.storage.request();
      return storageStatus.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      if (status.isGranted) return true;
      final result = await Permission.photos.request();
      return result.isGranted;
    }
    return false;
  }

  static Future<bool> requestAllPermissions() async {
    final audio = await requestAudioPermission();
    final video = await requestVideoPermission();
    return audio && video;
  }

  static Future<bool> hasAudioPermission() async {
    if (Platform.isAndroid) {
      return await Permission.audio.isGranted ||
          await Permission.storage.isGranted;
    }
    return await Permission.mediaLibrary.isGranted;
  }

  static Future<bool> hasVideoPermission() async {
    if (Platform.isAndroid) {
      return await Permission.videos.isGranted ||
          await Permission.storage.isGranted;
    }
    return await Permission.photos.isGranted;
  }
}
