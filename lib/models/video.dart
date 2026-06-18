import 'dart:convert';

class Video {
  final String id;
  final String title;
  final String filePath;
  final int durationMs;
  final String thumbnailPath;
  final int width;
  final int height;

  Video({
    required this.id,
    required this.title,
    required this.filePath,
    required this.durationMs,
    this.thumbnailPath = '',
    this.width = 0,
    this.height = 0,
  });

  Duration get duration => Duration(milliseconds: durationMs);

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'filePath': filePath,
        'durationMs': durationMs,
        'thumbnailPath': thumbnailPath,
        'width': width,
        'height': height,
      };

  factory Video.fromJson(Map<String, dynamic> json) => Video(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Unknown',
        filePath: json['filePath'] ?? '',
        durationMs: json['durationMs'] ?? 0,
        thumbnailPath: json['thumbnailPath'] ?? '',
        width: json['width'] ?? 0,
        height: json['height'] ?? 0,
      );

  String encode() => jsonEncode(toJson());

  factory Video.decode(String source) =>
      Video.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
