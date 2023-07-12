import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostDiscussionThreadPage extends ConsumerStatefulWidget {
  final String postid;
  const PostDiscussionThreadPage({super.key,required this.postid});
  @override
  _PostDiscussionThreadPageState createState() =>
      _PostDiscussionThreadPageState();
}

class _PostDiscussionThreadPageState extends ConsumerState<PostDiscussionThreadPage> {
  List<File> _thumbnails = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  bool isPost = false;

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _thumbnails.add(File(pickedImage.path));
      });
    }
  }



  void _removeThumbnail(int index) {
    setState(() {
      _thumbnails.removeAt(index);
    });
  }

  Future<void> postDiscussion() async{
    final user = ref.watch(userProvider);
    List<String> thumbnailUrls = [];
    setState(() {
      isPost = true;
    });
    try{

      for (File thumbnail in _thumbnails) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('thumbnails')
            .child('${DateTime
            .now()
            .millisecondsSinceEpoch}.jpg');
        await ref.putFile(thumbnail);
        final url = await ref.getDownloadURL();
        thumbnailUrls.add(url);
      }
      }catch(e){
      print(e);
    }
    final discussionData = DiscussionThread(author: user.username, comments: [], content: _contentController.text,
    downvotes: [], upvotes: [], postedAt: DateTime.now(), id: const Uuid().v1(), profilePhoto: user.photoUrl!,
    userid: user.uid, thumbnail: thumbnailUrls, title: _titleController.text, postid: widget.postid);
    try{
      final res = await FirebaseFirestore.instance
          .collection('discussions')
          .doc(widget.postid)
          .collection('daftarDiskusi').doc(discussionData.id).set(discussionData.toMap());

      setState(() {
        isPost = false;
      });

      // Reset form
      _formKey.currentState!.reset();

      // Clear thumbnails
      _thumbnails.clear();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Berhasil memposting diskusi')));
    }catch(e){
      print(e);
      setState(() {
        isPost = false;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Gagal memposting diskusi karena masalah jaringan')));
    }

  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        title: const Text('Posting Diskusi Baru', style: TextStyle(color: Colors.black),),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Judul',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tolong tulis judul diskusi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  decoration: InputDecoration(
                    labelText: 'Konten',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tolong tulis konten diskusi';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0),
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                  ),
                  itemCount: _thumbnails.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _thumbnails.length) {
                      return GestureDetector(
                        onTap: () async {
                          final source = await showDialog<ImageSource>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Pilih sumber gambar'),
                              content: Text('Pilih ingin mengambil gambar darimana'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, ImageSource.camera),
                                  child: Text('Kamera'),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, ImageSource.gallery),
                                  child: Text('Galeri'),
                                ),
                              ],
                            ),
                          );
                          if (source != null) {
                            _pickImage(source);
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    } else {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Image.file(
                              _thumbnails[index],
                              fit: BoxFit.cover,
                              height: double.infinity,
                              width: double.infinity,
                            ),
                            clipBehavior: Clip.antiAlias,
                          ),
                          Positioned(
                            top: 8.0,
                            right: 8.0,
                            child: GestureDetector(
                              onTap: () {
                                _removeThumbnail(index);
                              },
                              child: CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.red,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                  },
                ),
                SizedBox(height: 16.0),
                ElevatedButton(
                  style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.all(18))
                  )
                ,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      postDiscussion();
                    }
                  },
                  child: isPost? const CircularProgressIndicator() : const Text('Posting'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}