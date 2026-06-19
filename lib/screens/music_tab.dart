import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/music_provider.dart';
import '../models/song.dart';
import '../widgets/glass_card.dart';
import '../widgets/audio_visualizer.dart';
import 'now_playing_screen.dart';

class MusicTab extends StatelessWidget {
  const MusicTab({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Text(
                  'Music',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const Spacer(),
                if (musicProvider.isPlaying) const AudioVisualizer(),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: GlassCard(
              borderRadius: 16,
              padding: EdgeInsets.zero,
              child: TextField(
                onChanged: (value) => musicProvider.setSearchQuery(value),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                ),
                decoration: InputDecoration(
                  hintText: 'Search songs...',
                  hintStyle: TextStyle(
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDark ? Colors.white54 : Colors.black54,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
            child: Row(
              children: [
                Text(
                  '${musicProvider.songs.length} songs',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: musicProvider.isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  )
                : musicProvider.songs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.music_off_rounded,
                              size: 64,
                              color: isDark ? Colors.white24 : Colors.black26,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              kIsWeb
                                  ? 'Web player - load songs via URL'
                                  : 'No songs found',
                              style: TextStyle(
                                color: isDark ? Colors.white54 : Colors.black54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              kIsWeb
                                  ? 'Use the player to stream audio'
                                  : 'Check permissions or add music files',
                              style: TextStyle(
                                color: isDark ? Colors.white30 : Colors.black26,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => musicProvider.refresh(),
                        color: accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: musicProvider.songs.length,
                          itemBuilder: (context, index) {
                            final song = musicProvider.songs[index];
                            final isCurrent =
                                musicProvider.currentSong?.id == song.id;

                            return _SongTile(
                              song: song,
                              isCurrent: isCurrent,
                              isDark: isDark,
                              accent: accent,
                              onTap: () {
                                musicProvider.playSong(song);
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const NowPlayingScreen(),
                                  ),
                                );
                              },
                              onFavorite: () =>
                                  musicProvider.toggleFavorite(song),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  const _SongTile({
    required this.song,
    required this.isCurrent,
    required this.isDark,
    required this.accent,
    required this.onTap,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      onTap: onTap,
      accentColor: isCurrent ? accent : null,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: isCurrent
                    ? [accent, accent.withOpacity(0.6)]
                    : [
                        (isDark ? Colors.white12 : Colors.black12),
                        (isDark ? Colors.white24 : Colors.black26),
                      ],
              ),
            ),
            child: Icon(
              Icons.music_note,
              color: isCurrent ? Colors.white : (isDark ? Colors.white54 : Colors.black54),
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: TextStyle(
                    color: isCurrent
                        ? accent
                        : (isDark ? Colors.white : Colors.black87),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  song.artist,
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            _formatDuration(song.duration),
            style: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onFavorite,
            child: Icon(
              song.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: song.isFavorite
                  ? Colors.pinkAccent
                  : (isDark ? Colors.white38 : Colors.black38),
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
