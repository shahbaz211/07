import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String filePath;

  const VideoPreview({
    Key? key,
    required this.filePath,
  }) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController videoController;
  VoidCallback? videoPlayerListener;

  @override
  void initState() {
    _startVideoPlayer();
    super.initState();
  }

  @override
  void dispose() {
    videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: videoController.value.aspectRatio,
      // width: videoController.value.size.width,
      // height: videoController.value.size.height,
      child: VideoPlayer(videoController),
    );
    return AspectRatio(
      aspectRatio:
          videoController.value.size.height / videoController.value.size.width,
      // aspectRatio: 0.5,
      child: VideoPlayer(videoController),
    );
  }

  Future<void> _startVideoPlayer() async {
    videoController = VideoPlayerController.file(File(widget.filePath));

    videoPlayerListener = () {
      if (mounted) {
        setState(() {});
      }
      videoController.removeListener(videoPlayerListener!);
    };
    videoController.addListener(videoPlayerListener!);
    await videoController.setLooping(true);
    await videoController.initialize();
    // await videoController.dispose();
    await videoController.play();
    await Future.delayed(
      const Duration(milliseconds: 500),
      () {
        setState(() {});
      },
    );
  }
}
