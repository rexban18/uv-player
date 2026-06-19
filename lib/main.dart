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

late AudioHandler audioHandler;

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

  audioHandler = await AudioService.init(
    builder: () => AudioHandler(),
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
}
