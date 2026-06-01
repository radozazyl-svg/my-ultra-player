import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/video_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'mx_pro_player.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE videos(
            id TEXT PRIMARY KEY,
            path TEXT,
            name TEXT,
            size TEXT,
            duration INTEGER,
            thumbnailPath TEXT,
            dateAdded INTEGER,
            isFavorite INTEGER,
            lastPosition INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE playlists(
            id TEXT PRIMARY KEY,
            name TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE playlist_videos(
            playlistId TEXT,
            videoId TEXT,
            PRIMARY KEY (playlistId, videoId)
          )
        ''');
      },
    );
  }

  Future<void> insertVideo(VideoModel video) async {
    final db = await database;
    await db.insert('videos', video.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<VideoModel>> getVideos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('videos');
    return List.generate(maps.length, (i) => VideoModel.fromMap(maps[i]));
  }

  Future<void> updateVideo(VideoModel video) async {
    final db = await database;
    await db.update('videos', video.toMap(), where: 'id = ?', whereArgs: [video.id]);
  }

  Future<List<VideoModel>> getFavorites() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('videos', where: 'isFavorite = 1');
    return List.generate(maps.length, (i) => VideoModel.fromMap(maps[i]));
  }
}
