import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/comment_screen.dart';
import 'package:pantau/screen/resources_screen.dart';
import 'package:pantau/widgets/expandable_text.dart';
import 'package:pantau/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscussionContentScreen extends ConsumerStatefulWidget {

  final DiscussionThread discussion;
  final WidgetRef ref;
  final User user;
  final Function(WidgetRef) likeDiscussion;
  final Function(WidgetRef) dislikeDiscussion;
  const DiscussionContentScreen({super.key, required this.discussion, required this.user, required this.ref,
  required this.dislikeDiscussion, required this.likeDiscussion});
  @override
  _DiscussionContentScreenState createState() => _DiscussionContentScreenState();
}

class _DiscussionContentScreenState extends ConsumerState<DiscussionContentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int _currentImageIndex = 0;

  List<String>? _imageList;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _imageList = widget.discussion.thumbnail;
  }
  void updateComment(String uid){
    setState(() {
      widget.discussion.comments.add(uid);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Diskusi', style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body:  StreamBuilder(
    stream: FirebaseFirestore.instance
        .collection('discussions')
        .doc(widget.discussion.postid)
        .collection('daftarDiskusi')
        .snapshots(),builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
      return NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        widget.discussion.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      subtitle: Text(
                          'Oleh ' +widget.discussion.author  +' pada '+ DateFormat('dd MMM yyyy').format(widget.discussion.postedAt), style: TextStyle(color: Colors.grey)
                      ),
                      trailing: widget.discussion.profilePhoto.isEmpty? CircleAvatar(
                        radius: 16,
                          backgroundColor: Colors.grey,
                        child: Icon(Icons.person_rounded),
                      ):CircleAvatar(
                          radius: 16,
                          backgroundImage: NetworkImage(widget.discussion.profilePhoto)),
                    ),

                    SizedBox(height: 16.0),
                    ExpandableText(

                        text: widget.discussion.content)
                  ],
                ),
              ),
            ),
            if(widget.discussion.thumbnail.isNotEmpty)
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    CarouselSlider(
                      options: CarouselOptions(
                        height: 200,
                        viewportFraction: 0.8,
                        enableInfiniteScroll: true,
                        onPageChanged: (index, _) {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                      ),
                      items: _imageList!.map((imageUrl) {
                        return Builder(
                          builder: (BuildContext context) {
                            return Container(
                              margin: EdgeInsets.symmetric(horizontal: 4.0),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                    Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: Container(
                        padding: EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          '${_currentImageIndex + 1}/${_imageList!.length}',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),

              ),
            SliverToBoxAdapter(
                child:  ListTile(
                  title: Row(
                    children: [
                      TextButton.icon(onPressed: () {
                        widget.likeDiscussion(widget.ref);
                        setState(() {
                          if(widget.discussion.upvotes.contains(user.uid)){
                            widget.discussion.upvotes.remove(user.uid);
                          }else{
                            if(widget.discussion.downvotes.contains(user.uid)){
                              widget.discussion.downvotes.remove(user.uid);
                            }
                            widget.discussion.upvotes.add(user.uid);
                          }
                        });
                        },
                        icon: widget.discussion.upvotes.contains(widget.user.uid)? Icon(Icons.arrow_upward_rounded, color:  Colors.blue,) :
                        Icon(Icons.arrow_upward_rounded, color: Colors.black,)
                        , label: Text(widget.discussion.upvotes.length.toString(), style: TextStyle(color: Colors.black)),)
                      ,
                      SizedBox(width: 16),
                      TextButton.icon(onPressed: () {
                        widget.dislikeDiscussion(widget.ref);
                        setState(() {
                          if(widget.discussion.downvotes.contains(user.uid)){
                            widget.discussion.downvotes.remove(user.uid);
                          }else{
                            if(widget.discussion.upvotes.contains(user.uid)){
                              widget.discussion.upvotes.remove(user.uid);
                            }
                            widget.discussion.downvotes.add(user.uid);
                          }
                        });
                        },
                        icon: widget.discussion.downvotes.contains(widget.user.uid)? Icon(Icons.arrow_downward_rounded, color:  Colors.blue,) :
                        Icon(Icons.arrow_downward_rounded, color: Colors.black,)
                        , label: Text(widget.discussion.downvotes.length.toString(), style: TextStyle(color: Colors.black)),)
                      , SizedBox(width: 16),
                      TextButton.icon(onPressed: (){}, icon: Icon(Icons.comment,color: Colors.black,), label:
                      Text(widget.discussion.comments.length.toString(), style:
                      TextStyle(
                          color: Colors.black
                      ),)),
                      SizedBox(
                        width: 16,
                      ),
                      TextButton.icon(onPressed: (){}, icon: Icon(Icons.share, color: Colors.black,),
                          label: Text('Bagikan', style: TextStyle(color: Colors.black),))

                    ],
                  ),
                )
            ),
            SliverToBoxAdapter(
              child: TabBar(
                controller: _tabController,
                indicatorColor: Colors.blue,
                labelColor: Colors.blue,
                unselectedLabelColor: Colors.black,
                tabs: [
                  Tab(text: 'Komentar'),
                  Tab(text: 'Resources Terkait'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Konten Komentar
            CommentScreen(discussion: widget.discussion, updateComment: updateComment,),
            ResourceScreenTerkait(discussion: widget.discussion),
          ],
        ),
      )
    ;},
    ),);


}}