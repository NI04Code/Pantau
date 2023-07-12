import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantau/models/discussion_thread.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/screen/create_discussion_screen.dart';
import 'package:pantau/screen/resources_screen.dart';
import 'package:pantau/screen/search_discussion.dart';
import 'package:pantau/widgets/search_bar.dart';
import 'package:pantau/widgets/tile_discussion.dart';

enum SortDiskusi{
  DukunganTerbanyak,
  KomentarTerbanyak,
  Terbaru
}

class DiscussionScreen extends StatefulWidget{
  final String postid;
  final PostinganKasus kasus;

  const DiscussionScreen({super.key, required this.postid, required this.kasus});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _StateDiscussionScreen();
  }
}

class _StateDiscussionScreen extends State<DiscussionScreen>{
  SortDiskusi selectedOption = SortDiskusi.DukunganTerbanyak;
  void sortBy(SortDiskusi selected, List<DiscussionThread> list){
    if(selected == SortDiskusi.KomentarTerbanyak){
      list.sort((a,b) => b.comments.length.compareTo(a.comments.length));
    }
    else if(selected == SortDiskusi.DukunganTerbanyak){
      list.sort((a,b)=>b.upvotes.length.compareTo(a.upvotes.length));
    }
    else{
      list.sort((a,b)=> b.postedAt.compareTo(a.postedAt));
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(

      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('discussions')
            .doc(widget.postid)
            .collection('daftarDiskusi')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot){
          //print(snapshot.hasData);
          if(snapshot == null || snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(color: Colors.blue,),
            );
          }
          if(snapshot == null || ! snapshot.hasData){
              return Column(
                  children: [
                  SearchBarWidget(onSearch: (something){}, hintText: 'Cari di Forum Diskusi...',),
                  Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                  margin: const EdgeInsets.only(right: 10, top: 6, bottom:  6),
                  child: ElevatedButton(
                  onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PostDiscussionThreadPage(postid: widget.postid)));
                  // Logika ketika tombol ditekan
                  },
                  style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  ),
                  ),
                  child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Icon(Icons.post_add),
                  SizedBox(width: 8.0),
                  Text('Buat diskusi'),
                  ],
                  ),
                  ),
                  ),),

                  Container(
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,

                  children: [
                  Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                  Flexible(
                  flex: 1,
                  child: Container(
                  decoration: BoxDecoration(
                  color: Colors.blue, // Warna biru
                  borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: DropdownButtonHideUnderline(
                  child: DropdownButton(
                  iconEnabledColor: Colors.white60,
                  hint: Text('Urutkan', style: Theme.of(context).textTheme.bodyMedium,),
                  // Dropdown satu
                  dropdownColor: Colors.blue, // Warna biru untuk dropdown menu
                  items: [
                  DropdownMenuItem(
                  child: Text(
                  'Dukungan Terbanyak',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                  ),
                  value: '1',
                  ),
                  DropdownMenuItem(
                  child: Text(
                  'Komentar Terbanyak',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                  ),
                  value: '2',
                  ),
                  DropdownMenuItem(
                  child: Text(
                  'Terbaru',
                  style: TextStyle(color: Colors.white), // Warna teks putih
                  ),
                  value: '3',
                  ),
                  ],
                  onChanged: (value) {
                  // Logika ketika dropdown satu berubah
                  },
                  ),
                  ),
                  ),
                  ),
                  ],
                  ),
                  SizedBox(width: 16.0),
                  Flexible(
                  flex: 1,
                  child: Container(

                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8)
                  ),
                  child: TextButton.icon(onPressed: (){
                  Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ResourceScreen(kasus: widget.kasus,)));
                  },
                  icon: Icon(Icons.newspaper, color: Colors.white,), label: const Text('Resources',
                  style: TextStyle(
                  color: Colors.white
                  ),))
                  ),
                  ),
                  ],
                  ),
                  ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 48),
                              child: const Text('Belum ada diskusi. Jadilah yang pertama',
                                style: TextStyle(color: Colors.black, fontSize: 18),),
                            )


        ])

                  ;}
          final threads = snapshot.data!.docs.map((e) => DiscussionThread.fromMap(e.data() as Map<String, dynamic>)).toList();
          final threadsCopy = List<DiscussionThread>.of(threads);
          sortBy(selectedOption, threadsCopy);
          return
              SingleChildScrollView(
                child: Column(
                  children: [
                    SearchBarWidget(onSearch: (something){
                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                        return SearchDiscussionScreen(initialValue: something, threads: threads, kasus: widget.kasus);
                      }));
                    }, hintText: 'Cari di Forum Diskusi...',),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(right: 10, top: 6, bottom:  6),
                        child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => PostDiscussionThreadPage(postid: widget.postid)));
                          // Logika ketika tombol ditekan
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.post_add),
                            SizedBox(width: 8.0),
                            Text('Buat diskusi'),
                          ],
                        ),
                    ),
                      ),),

                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                flex: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue, // Warna biru
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<SortDiskusi>(
                                      value: selectedOption,
                                      iconEnabledColor: Colors.white60,
                                      hint: Text('Urutkan', style: Theme.of(context).textTheme.bodyMedium,),
                                      // Dropdown satu
                                      dropdownColor: Colors.blue, // Warna biru untuk dropdown menu
                                      items: [
                                        DropdownMenuItem(
                                          child: Text(
                                            'Dukungan Terbanyak',
                                            style: TextStyle(color: Colors.white), // Warna teks putih
                                          ),
                                          value: SortDiskusi.DukunganTerbanyak,
                                        ),
                                        DropdownMenuItem(
                                          child: Text(
                                            'Komentar Terbanyak',
                                            style: TextStyle(color: Colors.white), // Warna teks putih
                                          ),
                                          value: SortDiskusi.KomentarTerbanyak,
                                        ),
                                        DropdownMenuItem(
                                          child: Text(
                                            'Terbaru',
                                            style: TextStyle(color: Colors.white), // Warna teks putih
                                          ),
                                          value: SortDiskusi.Terbaru,
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          if(value!=null)
                                          selectedOption = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 16.0),
                          Flexible(
                            flex: 1,
                            child: Container(

                              padding: EdgeInsets.symmetric(horizontal: 16.0),
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(8)
                              ),
                              child: TextButton.icon(onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (ctx) => ResourceScreen(kasus: widget.kasus,)));
                              },
                                  icon: Icon(Icons.newspaper, color: Colors.white,), label: const Text('Resources',
                                  style: TextStyle(
                                    color: Colors.white
                                  ),))
                            ),
                          ),
                        ],
                      ),
                    ),
                    if(threadsCopy.isNotEmpty)...threadsCopy.map((discussionObject){
                      return CustomListTile(threads:discussionObject, post: widget.kasus, id: discussionObject.id, profilePictureurl: discussionObject.profilePhoto ,
                          postedAt: discussionObject.postedAt,title: discussionObject.title, username: discussionObject.author,
                          thumbnailUrls: discussionObject.thumbnail, likeCount: discussionObject.upvotes.length,
                          downvoteCount: discussionObject.downvotes.length, commentCount: discussionObject.comments.length);
                    }).toList()

                    else Container(
                      margin: EdgeInsets.symmetric(vertical: 48),
                      child: const Text('Belum ada diskusi. Jadilah yang pertama',
                        style: TextStyle(color: Colors.black, fontSize: 18),),
                    )
                  ],
                ),
              );
        },
      ),
    );
  }
}