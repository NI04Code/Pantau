import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:link_preview_generator/link_preview_generator.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/models/kasus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:uuid/uuid.dart';

String addUrlScheme(String url) {
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'http://' + url;
  }
  return url;
}

class ResourceScreen extends ConsumerStatefulWidget {
  final PostinganKasus kasus;
  const ResourceScreen({super.key, required this.kasus, });
  @override
  _ResourceScreenState createState() => _ResourceScreenState();
}

class _ResourceScreenState extends ConsumerState<ResourceScreen> {
  String? _link;


  Future<void> _sendLink(String url) async {
    final user = ref.watch(userProvider);
    final uniqueId = const Uuid().v1();
    try{
      await FirebaseFirestore.instance.collection('discussions').doc(widget.kasus.idPost).collection('resources').doc(
       uniqueId).set(
        {
          'link' : url,
          'resourceId' : uniqueId,
          'uid' : user.uid,
          'profil-picture' : user.photoUrl
        }
      );
    }
    catch(e){}
  }
  

  void _addLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController linkTextController = TextEditingController();

        return AlertDialog(
          title: Text('Tambahkan Link'),
          content: TextField(
            controller: linkTextController,
            decoration: InputDecoration(hintText: 'Masukkan link'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _link = linkTextController.text;
                  _sendLink(_link!);
                });
                linkTextController.clear();
              },
              child: Text('Tambah'),
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
        iconTheme: IconThemeData(
          color: Colors.black
        ),
        backgroundColor: Colors.white,
        title: Text('Resource', style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('discussions').doc(widget.kasus.idPost).collection('resources').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(color: Colors.blue,),
            );
          }
          List<String> listResources = snapshot.data!.docs.map((e) => addUrlScheme(e['link'] as String)).toList();
          print(listResources);
          if(listResources.isEmpty){
            return const Center(
              child: Text('Belum Ada Resources. Mulailah Menambahkan', style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),),
            );
          }

          return ListView.builder(itemCount: listResources.length,itemBuilder: (ctx, idx){
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: LinkPreviewGenerator(link: listResources[idx],
              linkPreviewStyle: idx % 2 == 0
              ? LinkPreviewStyle.large
                  : LinkPreviewStyle.small,),
            );
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLink,
        child: Icon(Icons.add),
      ),
    );
  }
}

class ResourceScreenTerkait extends ConsumerStatefulWidget {
  final DiscussionThread discussion;
  const ResourceScreenTerkait({super.key, required this.discussion, });
  @override
  _ResourceScreenTerkaitState createState() => _ResourceScreenTerkaitState();
}

class _ResourceScreenTerkaitState extends ConsumerState<ResourceScreenTerkait> {
  String? _link;


  Future<void> _sendLink(String url) async {
    final user = ref.watch(userProvider);
    final uniqueId = const Uuid().v1();
    try{
      await FirebaseFirestore.instance.collection('discussions').doc(widget.discussion.postid).collection('resources_terkait').doc(
          widget.discussion.id).collection('resources').doc(uniqueId).set(
          {
            'link' : url,
            'resourceId' : uniqueId,
            'uid' : user.uid,
            'profil-picture' : user.photoUrl
          }
      );
    }
    catch(e){}
  }


  void _addLink() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final TextEditingController linkTextController = TextEditingController();

        return AlertDialog(
          title: Text('Tambahkan Link'),
          content: TextField(
            controller: linkTextController,
            decoration: InputDecoration(hintText: 'Masukkan link'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _link = linkTextController.text;
                  _sendLink(_link!);
                });
                linkTextController.clear();
              },
              child: Text('Tambah'),
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

      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('discussions').doc(widget.discussion.postid).collection('resources_terkait').doc(
            widget.discussion.id).collection('resources').snapshots(),
        builder: (ctx, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(color: Colors.blue,),
            );
          }
          List<String> listResources = snapshot.data!.docs.map((e) => addUrlScheme(e['link'] as String)).toList();
          print(listResources);
          if(listResources.isEmpty){
            return const Center(
              child: Text('Belum Ada Resources. Mulailah Menambahkan', style: TextStyle(
                color: Colors.black,
                fontSize: 18,
              ),),
            );
          }

          return ListView.builder(itemCount: listResources.length,itemBuilder: (ctx, idx){
            return Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              child: LinkPreviewGenerator(link: listResources[idx],
                linkPreviewStyle: idx % 2 == 0
                    ? LinkPreviewStyle.large
                    : LinkPreviewStyle.small,),
            );
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addLink,
        child: Icon(Icons.add),
      ),
    );
  }
}