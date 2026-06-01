import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../models/video_model.dart';
import 'package:uuid/uuid.dart';

class VideoScanner {
  static Future<List<VideoModel>> scanVideos() async {
    List<VideoModel> videos = [];
    // ملاحظة: في بيئة الأندرويد الحقيقية، سنستخدم MediaStore أو فحص المجلدات الشائعة.
    // للتبسيط ولضمان العمل، سنقوم بفحص مجلدات معينة.
    
    List<Directory?> directories = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Movies'),
      Directory('/storage/emulated/0/DCIM/Camera'),
    ];

    String thumbDir = (await getTemporaryDirectory()).path;

    for (var dir in directories) {
      if (dir != null && await dir.exists()) {
        await for (var entity in dir.list(recursive: true, followLinks: false)) {
          if (entity is File && _isVideoFile(entity.path)) {
            String fileName = p.basename(entity.path);
            int fileSize = await entity.length();
            String sizeStr = _formatBytes(fileSize, 2);
            
            // في التطبيق الحقيقي سنستخدم مكتبة لاستخراج المدة، هنا سنضع قيمة افتراضية للتجربة
            // أو نستخدم video_player_platform_interface لاستخراجها.
            
            String? thumbPath = await VideoThumbnail.thumbnailFile(
              video: entity.path,
              thumbnailPath: thumbDir,
              imageFormat: ImageFormat.JPEG,
              maxWidth: 128,
              quality: 25,
            );

            videos.add(VideoModel(
              id: const Uuid().v4(),
              path: entity.path,
              name: fileName,
              size: sizeStr,
              duration: const Duration(minutes: 5), // قيمة افتراضية للتوضيح
              thumbnailPath: thumbPath,
              dateAdded: DateTime.now(),
            ));
          }
        }
      }
    }
    return videos;
  }

  static bool _isVideoFile(String path) {
    final extensions = ['.mp4', '.mkv', '.avi', '.mov', '.flv', '.wmv'];
    return extensions.contains(p.extension(path).toLowerCase());
  }

  static String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    var i = (bytes / 1024).floor();
    return ((bytes / (1024 * i)).toStringAsFixed(decimals)) + " " + suffixes[i];
  }
}
