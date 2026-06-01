import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';
import '../screens/video_player_screen.dart';
import 'package:share_plus/share_plus.dart';

class VideoListItem extends StatelessWidget {
  final VideoModel video;

  const VideoListItem({super.key, required this.video});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 80,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[800],
        ),
        child: video.thumbnailPath != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(File(video.thumbnailPath!), fit: BoxFit.cover),
              )
            : const Icon(Icons.movie, color: Colors.white),
      ),
      title: Text(video.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text('${video.size} • ${_formatDuration(video.duration)}'),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuAction(context, value),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'favorite',
            child: Row(
              children: [
                Icon(video.isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                const SizedBox(width: 8),
                Text(video.isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة'),
              ],
            ),
          ),
          const PopupMenuItem(
            value: 'share',
            child: Row(
              children: [
                Icon(Icons.share, color: Colors.blue),
                const SizedBox(width: 8),
                Text('مشاركة'),
              ],
            ),
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoPlayerScreen(video: video),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _handleMenuAction(BuildContext context, String action) {
    final provider = context.read<VideoProvider>();
    if (action == 'favorite') {
      provider.toggleFavorite(video);
    } else if (action == 'share') {
      Share.shareXFiles([XFile(video.path)], text: 'شاهد هذا الفيديو: ${video.name}');
    }
  }
}
