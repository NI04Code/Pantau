import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';


class AudioPlaylistPage extends StatefulWidget {
  final List<String> urls;

  AudioPlaylistPage({required this.urls});

  @override
  _AudioPlaylistPageState createState() => _AudioPlaylistPageState();
}

class _AudioPlaylistPageState extends State<AudioPlaylistPage> {
  late AudioPlayer _audioPlayer;
  PlayerState _audioPlayerState = PlayerState.stopped;
  Duration _duration = Duration();
  Duration _position = Duration();
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _audioPlayerState = state;
      });
    });
    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _duration = duration;
      });
    });
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _position = position;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAudio(int index) async {
    if (currentIndex == index) {
      if (_audioPlayerState == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } else {
      currentIndex = index;
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(widget.urls[index]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int index = 0; index < widget.urls.length; index++)
          ListTile(
            title: Text('Rekaman Suara ${index + 1}'),
            subtitle: Slider(
              onChanged: (double value) {
                final Duration newPosition = Duration(milliseconds: value.toInt());
                _audioPlayer.seek(newPosition);
              },
              value: _position.inMilliseconds.toDouble(),
              min: 0.0,
              max: _duration.inMilliseconds.toDouble(),
            ),
            trailing: IconButton(
              icon: Icon(
                currentIndex == index
                    ? (_audioPlayerState == PlayerState.playing
                    ? Icons.pause
                    : Icons.play_arrow)
                    : Icons.play_arrow,
              ),
              onPressed: () {
                _playAudio(index);
              },
            ),
          ),
      ],
    );
  }
}
