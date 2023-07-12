import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/models/chat.dart';
import 'package:pantau/screen/reply_screen.dart';
import 'package:pantau/widgets/chat_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:pantau/widgets/comment_toggle_sorting.dart';

const RELATIVE_PATH_CHAT = 'comment';
class CommentScreen extends ConsumerStatefulWidget{
  final DiscussionThread discussion;
  final void Function(String) updateComment;
  const CommentScreen({super.key, required this.discussion, required this.updateComment});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _CommentScreenState();
  }
}
class _CommentScreenState extends ConsumerState<CommentScreen>{
  final TextEditingController _controller = TextEditingController();
  SortingOption selectedOption = SortingOption.Populer;


  @override
  void dispose(){
    _controller.dispose();
    super.dispose();
  }
  void openReply(Comment chat){
    Navigator.of(context).push(MaterialPageRoute(builder: (context){
      return ReplyScreen(chat: chat, discussion: widget.discussion);
    }));
  }
  void sortBy(SortingOption option, List<Comment> comments){
    if(option == SortingOption.Terbaru){
      comments.sort(
          (commentA, commentB){
            if(commentA.timestamp.compareTo(commentB.timestamp) > 1){
              return -1;
            }
            if(commentA.timestamp.compareTo(commentB.timestamp) < 1){
              return 1;
            }
            return 0;
          }
      );
    }
    else if(option == SortingOption.Populer){
      comments.sort((commentA, commentB){
        if(commentA.likes.length - commentB.dislikes.length > commentB.likes.length - commentB.dislikes.length){
          return -1;
        }
        if(commentA.likes.length - commentB.dislikes.length < commentB.likes.length - commentB.dislikes.length){
          return 1;
        }
        return 0;
      });
    }
  }

  Future<void> sendComment (Comment comment) async{
    final user = ref.watch(userProvider);
    try{
      await FirebaseFirestore.instance..collection('discussions')
          .doc(widget.discussion.postid)
          .collection('daftarDiskusi').
      doc(widget.discussion.id).collection(RELATIVE_PATH_CHAT).doc(comment.idChat).set(
        comment.toMap()
      );
      await FirebaseFirestore.instance..collection('discussions')
          .doc(widget.discussion.postid)
          .collection('daftarDiskusi').
      doc(widget.discussion.id).update({
        'comments' : [...widget.discussion.comments,  user.uid]
      });
      widget.updateComment(user.uid);
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
    final user = ref.watch(userProvider);
    // TODO: implement build
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8),
            child: CommentSortingToggle(selectedOption: selectedOption, onOptionChanged: (selected){
              setState(() {
                selectedOption = selected;
              });
            }),
          ),
          Expanded(
            child: StreamBuilder(
              stream:  FirebaseFirestore.instance
                  .collection('discussions')
                  .doc(widget.discussion.postid)
                  .collection('daftarDiskusi').doc(widget.discussion.id).collection(RELATIVE_PATH_CHAT).snapshots(),
              builder: (context, snapshot){
                if(snapshot.hasData){
                  List<Comment> comments =  snapshot.data!.docs.map((raw) => Comment.fromMap(raw.data())).toList();
                  sortBy(selectedOption, comments);
                  if(comments.isEmpty){
                    return const Center(child: Text('Belum ada yang berkomentar. Jadilah yang pertama',style: TextStyle(color: Colors.black),));
                  }
                  final commentsCopy = List<Comment>.of(comments);
                  return ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (context,index){
                      return CommentDisplay(chat: commentsCopy[index], discussion: widget.discussion, openReply: openReply,);
                  });
                }
                else if(snapshot.hasError){
                  return const Center(child: Text('Terjadi kesalahan',style: TextStyle(color: Colors.black),));
                }
                else{
                  return const Center(child: CircularProgressIndicator());
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
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan balasan',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8.0),
                IconButton(
                  icon: Icon(Icons.send,color: Colors.blue,),
                  onPressed: () {
                    final idChat = const Uuid().v1();
                    Comment comment = Comment
                      (profilePhoto: user.photoUrl!, idChat: idChat, message: _controller.text,
                        uid: user.uid, username: user.username, timestamp: DateTime.now(),
                        replies: [], likes: [], dislikes: []);
                    // todo
                    sendComment(comment);
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
