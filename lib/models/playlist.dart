import 'dart:convert';

class Playlist {
  final String id;
  String name;
  List<String> songIds;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    List<String>? songIds,
    DateTime? createdAt,
  })  : songIds = songIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'songIds': songIds,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        id: json['id'] ?? '',
        name: json['name'] ?? 'Untitled',
        songIds: List<String>.from(json['songIds'] ?? []),
        createdAt:
            DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      );

  String encode() => jsonEncode(toJson());

  factory Playlist.decode(String source) =>
      Playlist.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
