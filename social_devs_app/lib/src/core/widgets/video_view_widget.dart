import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoViewWidget extends StatefulWidget {
  const VideoViewWidget({Key? key, required this.url}) : super(key: key);

  final String url;

  @override
  State<VideoViewWidget> createState() => _VideoViewWidgetState();
}

class _VideoViewWidgetState extends State<VideoViewWidget> {
  late VideoPlayerController controller;

  void playPause() => controller.value.isPlaying || controller.value.isInitialized
      ? controller.play()
      : controller.pause();

  @override
  void initState() {
    super.initState();

    controller = VideoPlayerController.network(
      widget.url,
    )..initialize().then((value) => setState(() {}));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 196.0,
          ),
          child: AspectRatio(
            aspectRatio: controller.value.aspectRatio,
            child: VideoPlayer(controller),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return IconButton(
                onPressed: () => playPause(),
                icon: controller.value.isPlaying
                    ? const SizedBox()
                    : const Icon(Icons.play_arrow_rounded, color: Colors.white),
              );
            },
          ),
        ),
      ],
    );
  }
}
