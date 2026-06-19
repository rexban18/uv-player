import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:audio_service/audio_service.dart';

import 'app.dart';
import 'services/audio_handler.dart';
import 'providers/theme_provider.dart';
import 'providers/music_provider.dart';
import 'providers/video_provider.dart';
import 'providers/playlist_provider.dart';

UVAudioHandler? _audioHandlerInstance;
bool audioServiceReady = false;

UVAudioHandler? get audioHandler => _audioHandlerInstance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => PlaylistProvider()),
      ],
      child: const UVPlayerApp(),
    ),
  );

  _initAudioService();
}

Future<void> _initAudioService() async {
  try {
    _audioHandlerInstance = await AudioService.init(
      builder: () => UVAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.uvplayer.app.audio.channel',
        androidNotificationChannelName: 'UV Player',
        androidNotificationChannelDescription: 'Controls for UV Player',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
        androidNotificationIcon: 'mipmap/ic_launcher',
        artDownscaleWidth: 300,
        artDownscaleHeight: 300,
      ),
    );
    audioServiceReady = true;
  } catch (e) {
    debugPrint('AudioService init failed: $e');
    audioServiceReady = false;
  }
}
