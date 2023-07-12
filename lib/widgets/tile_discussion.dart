import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/screen/discussion_content_screen.dart';

class CustomListTile extends ConsumerStatefulWidget {
  final String title;
  final String username;
  final List<String> thumbnailUrls;
  final int likeCount;
  final int downvoteCount;
  final int commentCount;
  final DateTime postedAt;
  final String profilePictureurl;
  final String id;
  final DiscussionThread threads;
  final PostinganKasus post;

  CustomListTile({
    required this.title,
    required this.username,
    required this.thumbnailUrls,
    required this.likeCount,
    required this.downvoteCount,
    required this.commentCount,
    required this.postedAt,
    required this.profilePictureurl,
    required this.id,
    required this.threads,
    required this.post
  });

  @override
  ConsumerState<CustomListTile> createState() {
    // TODO: implement createState
    return _CustomListTileState();
  }
}

  class _CustomListTileState extends ConsumerState<CustomListTile>{

  Future<void>likeStartingDiscussion(WidgetRef ref) async{
  final user = ref.watch(userProvider);
  if(widget.threads.upvotes.contains(user.uid)){
  widget.threads.upvotes.remove(user.uid);
  }else{
  if(widget.threads.downvotes.contains(user.uid)){
  widget.threads.downvotes.remove(user.uid);
  }
  widget.threads.upvotes.add(user.uid);
  }
  await FirebaseFirestore.instance.collection('discussions').doc(widget.post.idPost).collection('daftarDiskusi').doc(widget.id).update(
  {
  'upvotes' : widget.threads.upvotes,
  'downvotes' : widget.threads.downvotes
  }
  );
  }

  Future<void> dislikeStartingDiscussion(WidgetRef ref) async {
  final user = ref.watch(userProvider);
  if(widget.threads.downvotes.contains(user.uid)){
  widget.threads.downvotes.remove(user.uid);
  }else{
  if(widget.threads.upvotes.contains(user.uid)){
  widget.threads.upvotes.remove(user.uid);
  }
  widget.threads.downvotes.add(user.uid);
  }
  await FirebaseFirestore.instance.collection('discussions').doc(widget.post.idPost).collection('daftarDiskusi').doc(widget.id).update(
  {
  'upvotes' : widget.threads.upvotes,
  'downvotes' : widget.threads.downvotes
  }
  );
  }


  @override
  Widget build(BuildContext context) {
  final user = ref.watch(userProvider);
  return ListTile(
  onTap: (){
  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
  return DiscussionContentScreen(discussion: widget.threads, user: user,ref: ref,
  likeDiscussion: likeStartingDiscussion, dislikeDiscussion: dislikeStartingDiscussion,);
  }));
  },
  leading: widget.profilePictureurl.isEmpty?CircleAvatar(backgroundColor: Colors.grey,
      child: Icon(Icons.person_rounded),) : CircleAvatar(
  backgroundImage: NetworkImage(widget.profilePictureurl)),
  title: Text(widget.title, style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black)),
  subtitle: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
  Wrap(
  direction: Axis.horizontal,
  children: [
  Text(widget.threads.author, style: TextStyle(color: Colors.black),),
  Text(' pada '+ DateFormat('dd MMM yyyy').format(widget.postedAt), style: TextStyle(color: Colors.grey),)
  ],
  ),
  Row(
  children: [
  TextButton.icon(onPressed: () { likeStartingDiscussion(ref);},
  icon: widget.threads.upvotes.contains(user.uid)? Icon(Icons.arrow_upward_rounded, color: Colors.blue,) :
  Icon(Icons.arrow_upward_rounded, color: Colors.black,)
  , label: Text(widget.threads.upvotes.length.toString(), style: TextStyle(color: Colors.black)),)
  ,
  SizedBox(width: 16),
  TextButton.icon(onPressed: () { dislikeStartingDiscussion(ref);},
  icon: widget.threads.downvotes.contains(user.uid)? Icon(Icons.arrow_downward_rounded, color: Colors.blue,) :
  Icon(Icons.arrow_downward_rounded, color: Colors.black,)
  , label: Text(widget.threads.downvotes.length.toString(), style: TextStyle(color: Colors.black)),)
  , SizedBox(width: 16),
  Icon(Icons.comment),
  Text(widget.threads.comments.length.toString(), style: TextStyle(color: Colors.black)),
  ],
  ),
  ],
  ),
  trailing: Container(
  width: 80,
  child: ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: Image.network(
  widget.thumbnailUrls.isEmpty? 'https://firebasestorage.googleapis.com/v0/b/pantau-d0ef6.appspot.com/o/no-image-icon-23485.png?alt=media&token=9ed864b0-bd54-4f58-a7f8-7e76d89e7961' : widget.thumbnailUrls.first,
  fit: BoxFit.cover,
  ),
  ),
  ),
  );
  }
  }

