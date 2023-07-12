import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/chat.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantau/screen/comment_screen.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/screen/reply_screen.dart';


final emptyProfileIcon = 'https://firebasestorage.googleapis.com/v0/b/flutter-project-80041.appspot.com/o/user-svgrepo-com.png?alt=media&token=2c6ae392-ed2b-4f8a-961e-8707e067ba99';
class CommentDisplay extends ConsumerStatefulWidget{
  final Comment chat;
  final DiscussionThread discussion;
  final void Function(Comment chat) openReply;
  const CommentDisplay({
    required this.chat, super.key, required this.discussion, required this.openReply
});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _ChatDisplayState();
  }
}
class _ChatDisplayState extends ConsumerState<CommentDisplay>{

  final formattedTime = DateFormat('HH:mm');
  final formattedDate = DateFormat('dd-MM-yyyy');
  Future<void>likeStartingDiscussion() async{
    final user = ref.watch(userProvider);
    setState(() {
      if(widget.chat.likes.contains(user.uid)){
        widget.chat.likes.remove(user.uid);
      }else{
        if(widget.chat.dislikes.contains(user.uid)){
          widget.chat.dislikes.remove(user.uid);
        }
        widget.chat.likes.add(user.uid);
      }
    });

    await FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.postid)
        .collection('daftarDiskusi').doc(widget.discussion.id).collection('comment').doc(widget.chat.idChat).update(
      {
        'likes' : widget.chat.likes,
        'dislikes': widget.chat.dislikes
      }
    );
  }

  Future<void>dislikeStartingDiscussion() async{
    final user = ref.watch(userProvider);
    setState(() {
      if(widget.chat.dislikes.contains(user.uid)){
        widget.chat.dislikes.remove(user.uid);
      }else{
        if(widget.chat.likes.contains(user.uid)){
          widget.chat.likes.remove(user.uid);
        }
        widget.chat.dislikes.add(user.uid);
      }
    });

    await FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.postid)
        .collection('daftarDiskusi').doc(widget.discussion.id).collection('comment').doc(widget.chat.idChat).update(
        {
          'likes' : widget.chat.likes,
          'dislikes': widget.chat.dislikes
        }
    );
  }




  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    // TODO: implement build
    return GestureDetector(
      onTap: (){
        widget.openReply(widget.chat);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        child: ListTile(
          leading: GestureDetector(
            child: widget.chat.profilePhoto.isEmpty? CircleAvatar(radius: 20,
            child: Icon(Icons.person_rounded),backgroundColor: Colors.grey,):CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              backgroundImage: NetworkImage(widget.chat.profilePhoto),
            ),
          ),
          title: Text(widget.chat.username, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.chat.message, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
              GestureDetector(
                onTap: (){
                  widget.openReply(widget.chat);
                },
                child: Row(
                  children: [
                    TextButton.icon(onPressed: () {
                      likeStartingDiscussion();
                    },
                      icon: widget.chat.likes.contains(user.uid)? Icon(Icons.arrow_upward_rounded, color:  Colors.blue,) :
                      Icon(Icons.arrow_upward_rounded, color: Colors.black,)
                      , label: Text(widget.chat.likes.length.toString(), style: TextStyle(color: Colors.black)),)
                    ,
                    SizedBox(width: 16),
                    TextButton.icon(onPressed: () {
                      dislikeStartingDiscussion();
                    },
                      icon: widget.chat.dislikes.contains(user.uid)? Icon(Icons.arrow_downward_rounded, color:  Colors.blue,) :
                      Icon(Icons.arrow_downward_rounded, color: Colors.black,)
                      , label: Text(widget.chat.dislikes.length.toString(), style: TextStyle(color: Colors.black)),)
                    , SizedBox(width: 16),
                    GestureDetector(
                      onTap: (){
                        widget.openReply(widget.chat);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.comment),
                          Text(widget.chat.replies.length.toString(), style: TextStyle(color: Colors.black)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          trailing: Column(
            children: [
              Text(formattedDate.format(widget.chat.timestamp), style: TextStyle(color: Colors.black),),
              Text(formattedTime.format(widget.chat.timestamp), style: TextStyle(color: Colors.black),)
            ],
          ),
        ),
      ),
    );
  }
}


class ReplyDisplay extends ConsumerStatefulWidget{
  final Comment comment;
  final DiscussionThread discussion;
  final Reply reply;
  const ReplyDisplay({
    required this.reply, super.key, required this.comment, required this.discussion
  });
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _ReplyDisplayState();
  }
}
class _ReplyDisplayState extends ConsumerState<ReplyDisplay>{
  final formattedTime = DateFormat('HH:mm');
  final formattedDate = DateFormat('dd-MM-yyyy');
  Future<void>likeStartingDiscussion() async{
    final user = ref.watch(userProvider);
    if(widget.reply.likes.contains(user.uid)){
      widget.reply.likes.remove(user.uid);
    }else{
      if(widget.reply.dislikes.contains(user.uid)){
        widget.reply.dislikes.remove(user.uid);
      }
      widget.reply.likes.add(user.uid);
    }
    await FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.postid)
        .collection('daftarDiskusi').doc(widget.discussion.id).collection('comment').doc(widget.comment.idChat).
    collection(RELATIVE_PATH_REPLY).doc(widget.reply.idChat).update(
        {
          'likes' : widget.reply.likes,
          'dislikes': widget.reply.dislikes
        }
    );
  }

  Future<void>dislikeStartingDiscussion() async{
    final user = ref.watch(userProvider);
    if(widget.reply.dislikes.contains(user.uid)){
      widget.reply.dislikes.remove(user.uid);
    }else{
      if(widget.reply.likes.contains(user.uid)){
        widget.reply.likes.remove(user.uid);
      }
      widget.reply.dislikes.add(user.uid);
    }
    await FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.postid)
        .collection('daftarDiskusi').doc(widget.discussion.id).collection('comment').doc(widget.comment.idChat).
    collection(RELATIVE_PATH_REPLY).doc(widget.reply.idChat).update(
        {
          'likes' : widget.reply.likes,
          'dislikes': widget.reply.dislikes
        }
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    // TODO: implement build
    return ListTile(
      leading: GestureDetector(
        child: CircleAvatar(
          backgroundColor: Colors.white,
          backgroundImage: NetworkImage(widget.reply.profilePhoto.isEmpty? emptyProfileIcon : widget.reply.profilePhoto),
        ),
      ),
      title: Text(widget.reply.username, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.reply.message, style: TextStyle(color: Colors.black, fontWeight: FontWeight.w400),),
          Row(
            children: [
              TextButton.icon(onPressed: () {
                likeStartingDiscussion();
              },
                icon: widget.reply.likes.contains(user.uid)? Icon(Icons.arrow_upward_rounded, color:  Colors.blue,) :
                Icon(Icons.arrow_upward_rounded, color: Colors.black,)
                , label: Text(widget.reply.likes.length.toString(), style: TextStyle(color: Colors.black)),)
              ,
              SizedBox(width: 16),
              TextButton.icon(onPressed: () { dislikeStartingDiscussion();},
                icon: widget.reply.dislikes.contains(user.uid)? Icon(Icons.arrow_downward_rounded, color:  Colors.blue,) :
                Icon(Icons.arrow_downward_rounded, color: Colors.black,)
                , label: Text(widget.reply.dislikes.length.toString(), style: TextStyle(color: Colors.black)),)
              ,
            ],
          ),
        ],
      ),
      trailing: Column(
        children: [
          Text(formattedDate.format(widget.reply.timestamp), style: TextStyle(color: Colors.black),),
          Text(formattedTime.format(widget.reply.timestamp), style: TextStyle(color: Colors.black),)
        ],
      ),
    );
  }
}