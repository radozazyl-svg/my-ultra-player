import 'package:flutter/material.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.playlist_add, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('قوائم التشغيل ستظهر هنا'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // منطق إنشاء قائمة تشغيل جديدة
            },
            child: const Text('إنشاء قائمة تشغيل جديدة'),
          ),
        ],
      ),
    );
  }
}
