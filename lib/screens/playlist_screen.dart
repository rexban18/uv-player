import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/playlist_provider.dart';
import '../models/playlist.dart';
import '../widgets/glass_card.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = context.watch<PlaylistProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Playlists',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: accent,
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: playlistProvider.playlists.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.queue_music_rounded,
                    size: 64,
                    color: isDark ? Colors.white24 : Colors.black26,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No playlists yet',
                    style: TextStyle(
                      color: isDark ? Colors.white54 : Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create one',
                    style: TextStyle(
                      color: isDark ? Colors.white30 : Colors.black26,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: playlistProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = playlistProvider.playlists[index];
                return _PlaylistTile(
                  playlist: playlist,
                  isDark: isDark,
                  accent: accent,
                  onTap: () => _openPlaylist(context, playlist),
                  onDelete: () => _deletePlaylist(context, playlist),
                  onRename: () => _renamePlaylist(context, playlist),
                );
              },
            ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        title: Text(
          'Create Playlist',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'Playlist name',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PlaylistProvider>().createPlaylist(
                      controller.text.trim(),
                    );
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Create',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openPlaylist(BuildContext context, Playlist playlist) {
    // TODO: Navigate to playlist detail
  }

  void _deletePlaylist(BuildContext context, Playlist playlist) {
    context.read<PlaylistProvider>().deletePlaylist(playlist.id);
  }

  void _renamePlaylist(BuildContext context, Playlist playlist) {
    final controller = TextEditingController(text: playlist.name);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.white,
        title: Text(
          'Rename Playlist',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black87,
          ),
          decoration: InputDecoration(
            hintText: 'New name',
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.black38,
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<PlaylistProvider>().renamePlaylist(
                      playlist.id,
                      controller.text.trim(),
                    );
                Navigator.of(context).pop();
              }
            },
            child: Text(
              'Rename',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  final Playlist playlist;
  final bool isDark;
  final Color accent;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _PlaylistTile({
    required this.playlist,
    required this.isDark,
    required this.accent,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  accent.withOpacity(0.6),
                  accent.withOpacity(0.3),
                ],
              ),
            ),
            child: const Icon(
              Icons.queue_music_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playlist.name,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${playlist.songIds.length} songs',
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.black54,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            color: isDark ? const Color(0xFF1A1A2E) : Colors.white,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'rename',
                child: Text(
                  'Rename',
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'rename') onRename();
              if (value == 'delete') onDelete();
            },
          ),
        ],
      ),
    );
  }
}
