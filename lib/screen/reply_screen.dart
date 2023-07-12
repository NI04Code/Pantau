import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/widgets/chat_widget.dart';
import 'package:uuid/uuid.dart';
const RELATIVE_PATH_REPLY = 'reply';
const RELATIVE_PATH_CHAT = 'comment';

class ReplyScreen extends ConsumerStatefulWidget {
  final Comment chat;
  final DiscussionThread discussion;



  ReplyScreen({
    required this.chat,
    required this.discussion,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _ReplyScreenState();
  }
}

class _ReplyScreenState extends ConsumerState<ReplyScreen>{
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose(){
    _controller.dispose();
  }
  Future<void> sendReply() async{
    final user = ref.watch(userProvider);
    try{
      Reply reply = Reply(profilePhoto: user.photoUrl!,
          idChat: const Uuid().v1(),
          message: _controller.text,
          uid: user.username,
          username: user.username,
          timestamp: DateTime.now(),
          likes: [],
          dislikes: []);
      await FirebaseFirestore.instance.collection('discussions')
          .doc(widget.discussion.postid)
          .collection('daftarDiskusi').
      doc(widget.discussion.id).collection(RELATIVE_PATH_CHAT).doc(widget.chat.idChat).collection(RELATIVE_PATH_REPLY).doc(reply.idChat).set(
          reply.toMap()
      );
      setState(() {
        widget.chat.replies.insert(0, reply);
      });
      await FirebaseFirestore.instance.collection('discussions')
          .doc(widget.discussion.postid)
          .collection('daftarDiskusi').
      doc(widget.discussion.id).collection(RELATIVE_PATH_CHAT).doc(widget.chat.idChat).update(
        {
          'replies' : [...widget.chat.replies.map((reply) => reply.toMap()).toList(),]
        }
      );



      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.blue,content: Text('Berhasil memposting komentar')));
      _controller.clear();
    }catch(e){
      print(e);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.blue,content: Text('Gagal memposting komentar')));

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        title: Text('Balasan', style: TextStyle(
            color: Colors.black
        ),),
      ),
      body: Column(
        children: [
          CommentDisplay(chat: widget.chat, discussion: widget.discussion, openReply: (comment){}),
          Divider(
            color: Colors.blue,
            thickness: 5,
          ),

          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('discussions')
                  .doc(widget.discussion.postid)
                  .collection('daftarDiskusi').doc(widget.discussion.id).collection(RELATIVE_PATH_CHAT)
                  .doc(widget.chat.idChat).collection(RELATIVE_PATH_REPLY).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final replies = snapshot.data!.docs.map((reply) => Reply.fromMap(reply.data())).toList();
                  final repliesCopy = List<Reply>.of(replies);
                  repliesCopy.sort((a,b) => b.timestamp.compareTo(a.timestamp));
                  if(replies.isEmpty){
                    return Column(
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Center(child: Text('Belum ada balasan. Jadilah yang pertama', style:  TextStyle(color: Colors.black),),),
                      ],
                    );
                  }
                  return ListView.builder(
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      final reply = repliesCopy[index];
                      return ReplyDisplay(reply: reply, comment: widget.chat, discussion: widget.discussion,);
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Terjadi kesalahan',style: TextStyle(color: Colors.black),));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Container(
            color: Colors.grey[200],
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller:  _controller,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan balasan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send, color: Colors.blue,),
                  onPressed: () {
                    sendReply();
                    // todo
                    // Logika untuk mengirim balasan
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


