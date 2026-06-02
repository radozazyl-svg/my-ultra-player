import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/video_provider.dart';
import '../widgets/video_list_item.dart';
import 'favorites_screen.dart';
import 'playlists_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int _currentIndex = 0;

  final TextEditingController
      _searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    Future.delayed(
      Duration.zero,
      () {
        context
            .read<VideoProvider>()
            .loadVideos();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final videoProvider =
        context.watch<VideoProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MX Pro Player',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.sort),
            onPressed: () =>
                _showSortDialog(
                    context),
          ),
          IconButton(
            icon: const Icon(
                Icons.refresh),
            onPressed: () =>
                videoProvider
                    .loadVideos(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(
                  60),
          child: Padding(
            padding:
                const EdgeInsets.all(
                    8.0),
            child: TextField(
              controller:
                  _searchController,
              decoration:
                  InputDecoration(
                hintText:
                    'البحث عن فيديوهات...',
                prefixIcon:
                    const Icon(
                        Icons.search),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                              30),
                ),
                contentPadding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 0,
                ),
              ),
              onChanged: (value) {
                videoProvider
                    .searchVideos(
                        value);
              },
            ),
          ),
        ),
      ),
      body: _buildBody(
        _currentIndex,
        videoProvider,
      ),
      bottomNavigationBar:
          NavigationBar(
        selectedIndex:
            _currentIndex,
        onDestinationSelected:
            (index) {
          setState(() {
            _currentIndex =
                index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(
                Icons.video_library),
            label: 'المكتبة',
          ),
          NavigationDestination(
            icon:
                Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          NavigationDestination(
            icon: Icon(Icons
                .playlist_play),
            label:
                'قوائم التشغيل',
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    int index,
    VideoProvider provider,
  ) {
    if (provider.isLoading) {
      return const Center(
        child:
            CircularProgressIndicator(),
      );
    }

    switch (index) {
      case 0:
        return provider
                .videos.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد فيديوهات متاحة',
                ),
              )
            : ListView.builder(
                itemCount:
                    provider
                        .videos
                        .length,
                itemBuilder:
                    (context, i) {
                  return VideoListItem(
                    video: provider
                        .videos[i],
                  );
                },
              );

      case 1:
        return const FavoritesScreen();

      case 2:
        return const PlaylistsScreen();

      default:
        return Container();
    }
  }

  void _showSortDialog(
      BuildContext context) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(
        title:
            const Text('ترتيب حسب'),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            ListTile(
              title:
                  const Text(
                      'الاسم'),
              onTap: () {
                context
                    .read<
                        VideoProvider>()
                    .sortVideos(
                        'name');

                Navigator.pop(
                    context);
              },
            ),
            ListTile(
              title:
                  const Text(
                      'الحجم'),
              onTap: () {
                context
                    .read<
                        VideoProvider>()
                    .sortVideos(
                        'size');

                Navigator.pop(
                    context);
              },
            ),
            ListTile(
              title:
                  const Text(
                      'التاريخ'),
              onTap: () {
                context
                    .read<
                        VideoProvider>()
                    .sortVideos(
                        'date');

                Navigator.pop(
                    context);
              },
            ),
            ListTile(
              title:
                  const Text(
                      'المدة'),
              onTap: () {
                context
                    .read<
                        VideoProvider>()
                    .sortVideos(
                        'duration');

                Navigator.pop(
                    context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
