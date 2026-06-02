import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../models/video_model.dart';

class VideoScanner {
  static Future<List<VideoModel>> scanVideos() async {
    List<VideoModel> videos = [];

    List<Directory> directories = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Movies'),
      Directory('/storage/emulated/0/DCIM/Camera'),
    ];

    await getTemporaryDirectory();

    for (var dir in directories) {
      if (await dir.exists()) {
        await for (var entity
            in dir.list(recursive: true, followLinks: false)) {
          if (entity is File && _isVideoFile(entity.path)) {
            String fileName = p.basename(entity.path);

            int fileSize = await entity.length();

            String sizeStr = _formatBytes(fileSize, 2);

            videos.add(
              VideoModel(
                id: DateTime.now()
                    .millisecondsSinceEpoch
                    .toString(),
                path: entity.path,
                name: fileName,
                size: sizeStr,
                duration: const Duration(minutes: 5),
                thumbnailPath: null,
                dateAdded: DateTime.now(),
              ),
            );
          }
        }
      }
    }

    return videos;
  }

  static bool _isVideoFile(String path) {
    final extensions = [
      '.mp4',
      '.mkv',
      '.avi',
      '.mov',
      '.flv',
      '.wmv'
    ];

    return extensions.contains(
      p.extension(path).toLowerCase(),
    );
  }

  static String _formatBytes(
      int bytes,
      int decimals,
      ) {
    if (bytes <= 0) return "0 B";

    const suffixes = [
      "B",
      "KB",
      "MB",
      "GB",
      "TB"
    ];

    int i = 0;
    double size = bytes.toDouble();

    while (size >= 1024 &&
        i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }

    return "${size.toStringAsFixed(decimals)} ${suffixes[i]}";
  }
}
