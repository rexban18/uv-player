import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';

class NowPlayingScreen extends StatelessWidget {
  const NowPlayingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final song = musicProvider.currentSong;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    if (song == null) {
      return Scaffold(
        body: Center(
          child: Text(
            'No song playing',
            style: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Blurred Background
          if (!kIsWeb && song.artUri.isNotEmpty)
            Container(),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: Container(
              color: (isDark ? Colors.black : Colors.white).withOpacity(0.6),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  (isDark ? Colors.black : Colors.white).withOpacity(0.8),
                ],
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 32,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              'Now Playing',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              song.album,
                              style: TextStyle(
                                color: isDark ? Colors.white70 : Colors.black54,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                        onPressed: () => _showMoreOptions(context, song, isDark, accent),
                      ),
                    ],
                  ),
                ),

                const Spacer(flex: 2),

                // Album Art
                Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  height: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: _defaultArt(accent, isDark),
                  ),
                ),

                const Spacer(flex: 2),

                // Song Info
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      Text(
                        song.title,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.artist,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.black54,
                          fontSize: 15,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Seek Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: StreamBuilder<Duration>(
                    stream: musicProvider.positionStream,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return StreamBuilder<Duration?>(
                        stream: musicProvider.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          return Column(
                            children: [
                              SliderTheme(
                                data: SliderThemeData(
                                  trackHeight: 4,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                                  activeTrackColor: accent,
                                  inactiveTrackColor: isDark ? Colors.white24 : Colors.black26,
                                  thumbColor: accent,
                                  overlayColor: accent.withOpacity(0.2),
                                ),
                                child: Slider(
                                  value: position.inMilliseconds
                                      .toDouble()
                                      .clamp(0, duration.inMilliseconds.toDouble()),
                                  max: duration.inMilliseconds.toDouble() > 0
                                      ? duration.inMilliseconds.toDouble()
                                      : 1,
                                  onChanged: (value) {
                                    musicProvider.seek(Duration(milliseconds: value.toInt()));
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      _formatDuration(position),
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                    Text(
                                      _formatDuration(duration),
                                      style: TextStyle(
                                        color: isDark ? Colors.white54 : Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ),

                const SizedBox(height: 12),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Shuffle
                      IconButton(
                        icon: Icon(
                          Icons.shuffle,
                          color: musicProvider.isShuffle
                              ? accent
                              : (isDark ? Colors.white54 : Colors.black54),
                          size: 24,
                        ),
                        onPressed: () => musicProvider.toggleShuffle(),
                      ),

                      // Previous
                      IconButton(
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 36,
                        ),
                        onPressed: () => musicProvider.previous(),
                      ),

                      // Play/Pause
                      StreamBuilder<bool>(
                        stream: musicProvider.playingStream,
                        builder: (context, snapshot) {
                          final playing = snapshot.data ?? false;
                          return GestureDetector(
                            onTap: () => musicProvider.togglePlay(),
                            child: Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [accent, accent.withOpacity(0.8)],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.4),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Icon(
                                playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          );
                        },
                      ),

                      // Next
                      IconButton(
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: isDark ? Colors.white : Colors.black87,
                          size: 36,
                        ),
                        onPressed: () => musicProvider.next(),
                      ),

                      // Repeat
                      IconButton(
                        icon: Icon(
                          musicProvider.repeatMode == LoopMode.one
                              ? Icons.repeat_one
                              : Icons.repeat,
                          color: musicProvider.repeatMode != LoopMode.off
                              ? accent
                              : (isDark ? Colors.white54 : Colors.black54),
                          size: 24,
                        ),
                        onPressed: () => musicProvider.toggleRepeat(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Volume
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Row(
                    children: [
                      Icon(
                        Icons.volume_down,
                        color: isDark ? Colors.white54 : Colors.black54,
                        size: 20,
                      ),
                      Expanded(
                        child: SliderTheme(
                          data: SliderThemeData(
                            trackHeight: 3,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                            activeTrackColor: accent.withOpacity(0.7),
                            inactiveTrackColor: isDark ? Colors.white12 : Colors.black12,
                            thumbColor: accent,
                          ),
                          child: Slider(
                            value: 0.8,
                            onChanged: (value) => musicProvider.setVolume(value),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.volume_up,
                        color: isDark ? Colors.white54 : Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: song.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: song.isFavorite ? Colors.pinkAccent : (isDark ? Colors.white54 : Colors.black54),
                        onTap: () => musicProvider.toggleFavorite(song),
                      ),
                      _ActionButton(
                        icon: Icons.playlist_add,
                        color: isDark ? Colors.white54 : Colors.black54,
                        onTap: () {},
                      ),
                      _ActionButton(
                        icon: Icons.share,
                        color: isDark ? Colors.white54 : Colors.black54,
                        onTap: () => _shareSong(song),
                      ),
                      _ActionButton(
                        icon: Icons.lyrics_outlined,
                        color: isDark ? Colors.white54 : Colors.black54,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _shareSong(Song song) {
    Share.share(
      'Check out this song: ${song.title} by ${song.artist}\nPlayed on UV Player',
      subject: song.title,
    );
  }

  void _showMoreOptions(BuildContext context, Song song, bool isDark, Color accent) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: Icon(Icons.share, color: accent),
              title: Text('Share', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () {
                Navigator.pop(context);
                _shareSong(song);
              },
            ),
            ListTile(
              leading: Icon(Icons.info_outline, color: accent),
              title: Text('Song Info', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.playlist_add, color: accent),
              title: Text('Add to Playlist', style: TextStyle(color: isDark ? Colors.white : Colors.black87)),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _defaultArt(Color accent, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withOpacity(0.6), accent.withOpacity(0.3)],
        ),
      ),
      child: const Center(
        child: Icon(Icons.music_note_rounded, size: 80, color: Colors.white),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, color: color, size: 26),
    );
  }
}
