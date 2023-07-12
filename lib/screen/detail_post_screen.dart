

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantau/models/kasus.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/screen/detail_screen.dart';
import 'package:pantau/screen/discussion_screen.dart';
import 'package:pantau/screen/kontak_penting_input_screen.dart';
import 'package:pantau/screen/perkembangan_kasus_screen.dart';
import 'package:pantau/widgets/image_slider_custom.dart';
import 'package:pantau/widgets/tab_bar_view.dart';
import 'package:pantau/screen/contact_screen.dart';

class DetailPostScreen extends ConsumerStatefulWidget{

  final PostinganKasus kasus;
  final void Function(PlaceLocation) toMapkejahatan;
  final String profileUrl;
  final String currentLocation;
  const DetailPostScreen({required this.currentLocation,super.key,  required this.kasus, required this.toMapkejahatan, required this.profileUrl});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _DetailPostScreenState();
  }
}
class _DetailPostScreenState extends ConsumerState<DetailPostScreen> with SingleTickerProviderStateMixin{
  late  TabController _tabController;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: widget.kasus.jenisKasus == TipeKasus.LaporanCepat? 2 : 4, vsync: this);

  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text('Detail Kasus', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('posts').where(FieldPath.documentId, isEqualTo: widget.kasus.idPost).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(color: Colors.blue,),
            );
          }
          List<PostinganKasus> listKasus = snapshot.data!.docs.map((doc) => PostinganKasus.fromMap(doc.data())).toList();
          PostinganKasus currPost = listKasus.first;
          return NestedScrollView(headerSliverBuilder: (context, innerBoxIsScrolled){
            return [
              SliverToBoxAdapter(
                child: ImageCard(kasus: currPost,photoProfile: widget.profileUrl,),
              ),
              SliverToBoxAdapter(
                child: TabBar(
                  isScrollable: true,
                  controller: _tabController ,
                  indicatorColor: Colors.blue,
                  labelColor: Colors.blue,
                  unselectedLabelColor: Colors.black,
                  tabs: widget.kasus.jenisKasus == TipeKasus.LaporanCepat?[
                    Tab(text: 'Detail'),
                    Tab(text:  'Diskusi',),
                  ]:[
                    Tab(text: 'Detail'),
                    Tab(text: "Perkembangan Kasus",),
                    Tab(text:  'Diskusi',),
                    Tab(text: 'Kontak Penting',),
                  ]
                ),
              )
            ];
          }, body: TabBarView(
            controller: _tabController,
            children: widget.kasus.jenisKasus == TipeKasus.LaporanCepat?[
              DetailScreen(currentLocation: widget.currentLocation,kasus: currPost, toMapKejahatan: widget.toMapkejahatan,),
              DiscussionScreen(
                kasus: currPost,
                postid:  currPost.idPost,
              ),
            ]:[
              DetailScreen(currentLocation: widget.currentLocation,kasus: currPost, toMapKejahatan: widget.toMapkejahatan,),
              PerkembanganKasusScreen(kasus:  widget.kasus,),
              DiscussionScreen(
                kasus: currPost,
                  postid:  currPost.idPost,
              ),
              KontakScreen(kasus: currPost,)
            ],
          )

          );
        },
      ),
    );
  }
        

}
