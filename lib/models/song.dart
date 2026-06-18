import 'dart:convert';

class Song {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String artUri;
  final String filePath;
  final int durationMs;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.artUri,
    required this.filePath,
    required this.durationMs,
    this.isFavorite = false,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'artUri': artUri,
        'filePath': filePath,
        'durationMs': durationMs,
        'isFavorite': isFavorite,
      };

  factory Song.fromJson(Map<String, dynamic> json) => Song(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Unknown',
        artist: json['artist'] ?? 'Unknown Artist',
        album: json['album'] ?? 'Unknown Album',
        artUri: json['artUri'] ?? '',
        filePath: json['filePath'] ?? '',
        durationMs: json['durationMs'] ?? 0,
        isFavorite: json['isFavorite'] ?? false,
      );

  String encode() => jsonEncode(toJson());

  factory Song.decode(String source) =>
      Song.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
