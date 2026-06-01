class VideoModel {
  final String id;
  final String path;
  final String name;
  final String size;
  final Duration duration;
  final String? thumbnailPath;
  final DateTime dateAdded;
  bool isFavorite;
  Duration lastPosition;

  VideoModel({
    required this.id,
    required this.path,
    required this.name,
    required this.size,
    required this.duration,
    this.thumbnailPath,
    required this.dateAdded,
    this.isFavorite = false,
    this.lastPosition = Duration.zero,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'path': path,
      'name': name,
      'size': size,
      'duration': duration.inMilliseconds,
      'thumbnailPath': thumbnailPath,
      'dateAdded': dateAdded.millisecondsSinceEpoch,
      'isFavorite': isFavorite ? 1 : 0,
      'lastPosition': lastPosition.inMilliseconds,
    };
  }

  factory VideoModel.fromMap(Map<String, dynamic> map) {
    return VideoModel(
      id: map['id'],
      path: map['path'],
      name: map['name'],
      size: map['size'],
      duration: Duration(milliseconds: map['duration']),
      thumbnailPath: map['thumbnailPath'],
      dateAdded: DateTime.fromMillisecondsSinceEpoch(map['dateAdded']),
      isFavorite: map['isFavorite'] == 1,
      lastPosition: Duration(milliseconds: map['lastPosition']),
    );
  }
}
