import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:io';

class RecordingDialog extends StatefulWidget {
  final FlutterSoundRecorder recorder;
  final void Function(File?) addRecording;
  const RecordingDialog({super.key, required this.recorder, required this.addRecording});
  @override
  _RecordingDialogState createState() => _RecordingDialogState();
}

class _RecordingDialogState extends State<RecordingDialog> {
  bool isPlaying = true;
  @override
  void initState() {
    super.initState();
    _startRecording();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _startRecording()async {
    // Start recording logic
    await widget.recorder.startRecorder(toFile: 'audio');


  }

  void _pauseRecording() async{
    await widget.recorder.pauseRecorder();
    setState(() {
      isPlaying = false;
    });
  }

  Future _finishRecording()async{
    // Stop recording logic
    final path = await widget.recorder.stopRecorder();
    Navigator.of(context).pop();
    widget.addRecording(File(path!));
  }
  void _resumeRecording() async{
    await widget.recorder.resumeRecorder();
    setState(() {
      isPlaying = true;
    });
  }

  void _cancelRecording() async{
    await widget.recorder.stopRecorder();
    Navigator.pop(context);
    widget.addRecording(null);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12,),
          StreamBuilder<RecordingDisposition>(
              stream: widget.recorder.onProgress,
              builder: (context, snapshot){
                final duration = snapshot.hasData? snapshot.data!.duration :
                    Duration.zero;
                String twoDigits(int n)=> n.toString().padLeft(2,'0');
                final minutes = twoDigits(duration.inMinutes.remainder(60));
                final seconds = twoDigits(duration.inSeconds.remainder(60));
                return Text('$minutes:$seconds', style: TextStyle(
                  color: Colors.black,
                  fontSize: 20
                ),);
              }),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(onPressed: (){
                if(isPlaying) {
                  _pauseRecording();
                }
                else{
                  _resumeRecording();
                }
    }, icon: Icon(isPlaying?Icons.pause: Icons.play_arrow, size: 32, color: Colors.blue,)),
              IconButton(onPressed: (){
                _finishRecording();
              }, icon: Icon(Icons.stop_circle_sharp, size: 32, color:  Colors.blue,)),
              IconButton(onPressed: (){
                _cancelRecording();
              }, icon: Icon(Icons.cancel_rounded, size: 32, color: Colors.blue,))
            ],
          )
        ],
      )
    );
  }
}