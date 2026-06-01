import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:auto_orientation/auto_orientation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../models/video_model.dart';
import '../providers/video_provider.dart';

class VideoPlayerScreen extends StatefulWidget {
  final VideoModel video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool _isLocked = false;
  double _brightness = 0.5;
  double _volume = 0.5;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    WakelockPlus.enable();
    AutoOrientation.landscapeRightMode();
  }

  Future<void> _initializePlayer() async {
    _videoPlayerController = VideoPlayerController.file(File(widget.video.path));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      startAt: widget.video.lastPosition,
      aspectRatio: _videoPlayerController.value.aspectRatio,
      showControls: true,
      allowFullScreen: true,
      fullScreenByDefault: true,
      deviceOrientationsAfterFullScreen: [DeviceOrientation.portraitUp],
      playbackSpeeds: [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 3.0, 4.0],
      materialProgressColors: ChewieProgressColors(
        playedColor: Colors.blue,
        handleColor: Colors.blueAccent,
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white,
      ),
    );

    _videoPlayerController.addListener(() {
      if (_videoPlayerController.value.position != Duration.zero) {
        context.read<VideoProvider>().updateLastPosition(widget.video, _videoPlayerController.value.position);
      }
    });

    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    WakelockPlus.disable();
    AutoOrientation.portraitUpMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
                ? GestureDetector(
                    onVerticalDragUpdate: (details) => _handleVerticalDrag(details),
                    onDoubleTapDown: (details) => _handleDoubleTap(details),
                    child: Chewie(controller: _chewieController!),
                  )
                : const CircularProgressIndicator(),
          ),
          if (_isLocked)
            Positioned.fill(
              child: GestureDetector(
                onTap: () => setState(() => _isLocked = false),
                child: Container(
                  color: Colors.transparent,
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white, size: 50),
                  ),
                ),
              ),
            ),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(_isLocked ? Icons.lock : Icons.lock_open, color: Colors.white),
              onPressed: () => setState(() => _isLocked = !_isLocked),
            ),
          ),
        ],
      ),
    );
  }

  void _handleVerticalDrag(DragUpdateDetails details) async {
    if (_isLocked) return;
    
    double delta = details.primaryDelta! / MediaQuery.of(context).size.height;
    if (details.localPosition.dx < MediaQuery.of(context).size.width / 2) {
      // التحكم بالسطوع
      _brightness = (_brightness - delta).clamp(0.0, 1.0);
      await ScreenBrightness().setScreenBrightness(_brightness);
    } else {
      // التحكم بالصوت
      _volume = (_volume - delta).clamp(0.0, 1.0);
      VolumeController().setVolume(_volume);
    }
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_isLocked) return;
    
    final width = MediaQuery.of(context).size.width;
    if (details.localPosition.dx < width / 2) {
      // ترجيع 10 ثواني
      final newPos = _videoPlayerController.value.position - const Duration(seconds: 10);
      _videoPlayerController.seekTo(newPos < Duration.zero ? Duration.zero : newPos);
    } else {
      // تقديم 10 ثواني
      final newPos = _videoPlayerController.value.position + const Duration(seconds: 10);
      _videoPlayerController.seekTo(newPos);
    }
  }
}
