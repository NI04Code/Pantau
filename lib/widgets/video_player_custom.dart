import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoBox extends StatefulWidget {
  final String urlString;

  const VideoBox({required this.urlString});

  @override
  State<StatefulWidget> createState() {
    return _VideoBoxState();
  }
}

class _VideoBoxState extends State<VideoBox> {
  late VideoPlayerController _videoPlayerController;
  bool _isVideoInitialized = false;
  double _sliderValue = 0.0;

  @override
  Widget build(BuildContext context) {
    return _isVideoInitialized
        ? Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10)),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 300,
              child: AspectRatio(
                aspectRatio: 1,
                child: VideoPlayer(_videoPlayerController),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      if (_videoPlayerController.value.isPlaying) {
                        _videoPlayerController.pause();
                      } else {
                        _videoPlayerController.play();
                      }
                    },
                    icon: Icon(
                      _videoPlayerController.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.blue,
                      size: 56,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      _videoPlayerController.seekTo(Duration.zero);
                      _videoPlayerController.play();
                    },
                    icon: Icon(
                      Icons.replay,
                      color: Colors.blue,
                      size: 56,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Slider(
                value: _sliderValue,
                min: 0.0,
                max: _videoPlayerController.value.duration.inSeconds.toDouble(),
                onChanged: (value) {
                  setState(() {
                    _sliderValue = value;
                  });
                  _videoPlayerController.seekTo(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ],
        ),
      ),
    )
        : Container(
      width: MediaQuery.of(context).size.width,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _initializeVideo() async {
    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.urlString)
    );

    try {
      await _videoPlayerController.initialize();
      setState(() {
        _isVideoInitialized = true;
      });
    } catch (e) {
      print('Error initializing video: $e');
    }
  }
}