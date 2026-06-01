import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../widgets/video_list_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<VideoProvider>().videos.where((v) => v.isFavorite).toList();

    return favorites.isEmpty
        ? const Center(child: Text('لا توجد فيديوهات في المفضلة'))
        : ListView.builder(
            itemCount: favorites.length,
            itemBuilder: (context, i) => VideoListItem(video: favorites[i]),
          );
  }
}
