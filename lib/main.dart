import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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
    if (kIsWeb) {
      _audioHandlerInstance = UVAudioHandler();
      audioServiceReady = true;
    } else {
      await _initAudioServiceNative();
    }
  } catch (e) {
    debugPrint('AudioService init failed: $e');
    audioServiceReady = false;
  }
}

Future<void> _initAudioServiceNative() async {
  // Uses audio_service package (mobile only)
  // This import is deferred via conditional export
  try {
    _audioHandlerInstance = UVAudioHandler();
    audioServiceReady = true;
  } catch (e) {
    debugPrint('Native AudioService init failed: $e');
    audioServiceReady = false;
  }
}
