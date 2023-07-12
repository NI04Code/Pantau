import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/resources/auth.dart';
import 'package:pantau/widgets/location-widget.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';
import 'package:pantau/widgets/audio_recording.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kontak_penting.dart';



class QuickReportPage extends ConsumerStatefulWidget {
  @override
  _QuickReportPageState createState() => _QuickReportPageState();
}

class _QuickReportPageState extends ConsumerState<QuickReportPage> {
  List<File> imageFiles = [];
  List<File> audioFiles = [];
  List<File> videoFiles = [];
  List<String> videoThumbnails = [];
  final recorder = FlutterSoundRecorder();
  bool isPlaying = false;
  VideoPlayerController? _videoPlayerController;
  PlaceLocation? currentLocation;

  @override
  void initState() {
    super.initState();
    initRecorder();
  }

  initRecorder() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw 'Microphone access denied';
    }
    await recorder.openRecorder();
    recorder.setSubscriptionDuration(Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    super.dispose();
  }

  void _deleteAudio(int index) {
    setState(() {
      audioFiles.removeAt(index);
    });
  }

  Future<void> _showImagePickerDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ambil Gambar'),
          content: Text('Pilih sumber gambar'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _takePicture();
              },
              child: Text('Kamera'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _pickImageFromGallery();
              },
              child: Text('Galeri'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _takePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
    );

    if (pickedImage != null) {
      setState(() {
        imageFiles.add(File(pickedImage.path));
      });
    }
  }
  Future<void> buatPostingan ()async{
    final user = ref.watch(userProvider);
    List<String> image = [];
    List<String> audio = [];
    List<String> video = [];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Sedang memposting kasus')));
    try{
      for(final file in imageFiles){
        image.add(await Auth.instance.uploadImageToStorage(childName: 'posts', file: file.readAsBytesSync(), isPost: true));
      }
      for(final file in audioFiles){
        audio.add(await Auth.instance.uploadImageToStorage(childName: 'posts', file: file.readAsBytesSync(), isPost: true));
      }
      for(final file in videoFiles){
        video.add(await Auth.instance.uploadImageToStorage(childName: 'posts', file: file.readAsBytesSync(), isPost: true));
      }
    }catch(e){}
    final lat = currentLocation!.latitude;
    final lng = currentLocation!.longitude;

    final contact = KontakPenting(noTelephone: {}, mapMedsos:
    {
      'facebook' : '',
      'twitter' : '',
      'instagram':'',
      'linkedIn':''
    }, email: {});
    PostinganKasus kasus = PostinganKasus
      (uid: user.uid, thumbnail: image.isEmpty?'':image.first, idPost: const Uuid().v1(),
        username: user.username, waktuPemostingan: TimeOfDay.now(),
        judul: '', waktuTerjadinyaKasus: TimeOfDay.now(),
        deskripsi: '', jenisKasus: TipeKasus.LaporanCepat, lokasi: '$lat,$lng',
        tanggalTerjadinyaKasus: DateTime.now(), tanggalPemostingan: DateTime.now(),
        gambarUrls: image, komentar: [], upvote: [], diikuti: [],
        downvote: [], namaKorban: user.name, keteranganKorban: '',
        kontakPenting: contact, kronologis: [], rekamanSuara: audio, video: video);
    try{

      final res = await Auth.instance.firebase.collection('posts').doc(kasus.idPost).set(
          kasus.toMap());
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Berhasil memposting kasus')));
    }catch(e){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Gagal memposting kasus')));
    }
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        imageFiles.add(File(pickedImage.path));
      });
    }
  }

  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    final pickedVideo = await picker.pickVideo(source: ImageSource.camera);

    if (pickedVideo != null) {
        final thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: pickedVideo.path,
          thumbnailPath: (await Directory.systemTemp).path,
          imageFormat: ImageFormat.PNG,
          maxHeight: 64,
          quality: 30,
        );
      setState(() {
        videoThumbnails.add(thumbnailPath!);
        videoFiles.add(File(pickedVideo.path));
      });
    }
  }

  void _deleteImage(int index) {
    setState(() {
      imageFiles.removeAt(index);
    });
  }

  Future<void> _playVideo(String videoPath) async {
    if (_videoPlayerController != null) {
      await _videoPlayerController!.dispose();
    }
    _videoPlayerController = VideoPlayerController.file(File(videoPath));
    await _videoPlayerController!.initialize();
    await _videoPlayerController!.play();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
                ElevatedButton(
                  onPressed: () {
                    _videoPlayerController!.pause();
                    Navigator.of(context).pop();
                  },
                  child: Text('Tutup'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  void _showDeleteVideoDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hapus Video'),
          content: Text('Apakah Anda yakin ingin menghapus video ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteVideo(videoFiles[index]);
              },
              child: Text('Hapus'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        title: Text('Quick Report', style: TextStyle(color: Colors.black),),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rekam Video',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.black),
                        ),
                        IconButton(
                          onPressed: _recordVideo,
                          iconSize: 32.0,
                          icon: Icon(Icons.video_call_outlined, color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    videoFiles.isNotEmpty
                        ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                      children:
                          [
                            for(int i = 0; i < videoFiles.length; i++) Container(
                              margin: EdgeInsets.only(right: 6),
                              child: InkWell(
                                      onTap: ()=>_playVideo(videoFiles[i].path),
                                onLongPress: (){
                                        _showDeleteVideoDialog(i);
                                },
                                child: Stack(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:  BorderRadius.circular(12)
                                      ),
                                    height: 180,
                                    child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.file(File.fromUri(Uri.parse(videoThumbnails[i])), fit: BoxFit.cover ),
                                    ),
                                    ),
                                    Icon(Icons.play_arrow, size: 48, color: Colors.blue,)
                                  ],
                                ),
                                ),
                            )
                          ]
                    ),
                        )
                        : Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          'Belum ada video',
                          style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w200),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Rekam Suara',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.black),
                        ),
                        IconButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => RecordingDialog(
                                recorder: recorder,
                                addRecording: (file) {
                                  if (file == null) return;
                                  setState(() {
                                    audioFiles.add(file!);
                                  });
                                },
                              ),
                            );
                          },
                          iconSize: 32.0,
                          icon: Icon(recorder.isRecording ? Icons.stop_circle_outlined : Icons.mic_none, color: Colors.blue),
                        ),
                      ],
                    ),
                    if (audioFiles.isEmpty)
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: Center(
                          child: Text(
                            'Tidak ada rekaman suara',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w200,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      for (int index = 0; index < audioFiles.length; index++)
                        ListTile(
                          title: Text(
                            'Rekaman $index',
                            style: TextStyle(color: Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () {
                                  _deleteAudio(index);
                                },
                              ),
                            ],
                          ),
                        ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ambil Gambar',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(color: Colors.black),
                        ),
                        IconButton(
                          onPressed: _showImagePickerDialog,
                          iconSize: 32.0,
                          icon: Icon(Icons.add_a_photo_outlined, color: Colors.blue),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.0),
                    imageFiles.isNotEmpty
                        ? Row(
                      children: imageFiles.map((file) {
                        return Container(
                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                          margin: EdgeInsets.only(right: 8.0),
                          height: 120,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child:Stack(
                              children: [
                                Image.file(
                                  file,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: IconButton(
                                    onPressed: () => _deleteImage(imageFiles.indexOf(file)),
                                    icon: Icon(Icons.close),
                                    color: Colors.red,
                                  ),
                                ),
                              ],
                            ),
                          )
                        );
                      }).toList(),
                    )
                        : Container(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: Center(
                        child: Text(
                          'Belum ada gambar',
                          style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.w200),
                        ),
                      ),
                    ),
                    SizedBox(height: 8.0),

                    LocationWidget(onSelected: (selected) {
                      currentLocation = selected;
                    }),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                buatPostingan();
                // Logika untuk mengirim laporan
              },
              child: Text('Kirim Laporan ke Pantau'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteVideo(File file) {
    setState(() {
      videoFiles.remove(file);
    });
  }
}