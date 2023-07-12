import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/message.dart';
import 'package:pantau/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau/resources/auth.dart';
import 'package:pantau/screen/pesan_screen.dart';
import 'dart:io';

import 'package:pantau/widgets/postcard_widget.dart';
import 'package:uuid/uuid.dart';

class OtherUserProfilePage extends ConsumerWidget {
  User user;

  OtherUserProfilePage({required this.user});




  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(userProvider);
    return Scaffold(

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('users').where(
                      'uid', isEqualTo: user.uid).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Center(child: CircularProgressIndicator(),); else {
                      List<User> users = snapshot.data!.docs!.map((e) =>
                          User.buildUser(e)).toList();
                      user = users.first;
                      print(users.first.convertJSON());
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.only(
                                bottom: 20, left: 20, right: 20),
                            decoration: BoxDecoration(color: Colors.blue
                                .shade400),
                            child: Column(
                              children: [
                                SizedBox(height: 20),
                                if(user.photoUrl!.isNotEmpty)
                                  Container(

                                    child: CircleAvatar(
                                        radius: 64,
                                        backgroundImage: NetworkImage(
                                            user.photoUrl!)
                                    ),
                                  ) else
                                  Container(
                                    //color: Colors.red,
                                    child: CircleAvatar(
                                      radius: 64,
                                      child: Icon(Icons.person_rounded,
                                        color: Colors.white, size: 72,),
                                      backgroundColor: Colors.grey,
                                    ),
                                  ),
                                SizedBox(height: 20),
                                Text(
                                  user.name,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,

                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  '@${user.username}',
                                  style: TextStyle(
                                    fontSize: 16,

                                  ),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  user.bio.isNotEmpty
                                      ? user.bio
                                      : 'Tidak ada bio',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 3,
                                  style: TextStyle(
                                    fontSize: 16,
                                    // Teks gelap
                                  ),
                                ),
                                SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment
                                      .spaceEvenly,
                                  children: [
                                    Column(
                                      children: [
                                        Text(
                                          'Following',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          user.following.length.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          'Followers',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          user.followers.length.toString(),
                                          style: TextStyle(
                                            fontSize: 20,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 ,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(onPressed: () async{
                                      
                                      final result = await FirebaseFirestore.instance.collection
                                        ('rooms').where('uid',arrayContains: user.uid ).get();
                                      final rooms = result.docs.map((e) => Room.fromMap(e.data())).toList();
                                      final potentialRooms = rooms.where((element) => element.uid.contains(currentUser.uid)).toList();
                                      if(potentialRooms.isEmpty){
                                          Room newRoom
                                          = Room(uid: [currentUser.uid, user.uid],
                                              users: [currentUser, user], roomId: const Uuid().v1(), messages: []);
                                          await FirebaseFirestore.instance.collection('rooms').doc(newRoom.roomId).set(newRoom.toMap());
                                          Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                            return RoomPage(room: newRoom);
                                          }));

                                      }
                                      else{
                                        Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                          return RoomPage(room: rooms.first);
                                        }));
                                      }

                                    }, icon: Icon(Icons.chat_sharp, size: 36,color: Colors.white54,)),
                                    IconButton(onPressed: (){}, icon: Icon(Icons.favorite, size: 36, color: Colors.white54,))
                                  ],
                                ),

                              ],
                            ),
                          )
                          ,
                        ],
                      );
                    }
                  }
              ),
              StreamBuilder(
                  stream: FirebaseFirestore.instance.collection('posts').where(
                      'uid', isEqualTo: user.uid
                  ).snapshots(),
                  builder: (context, snapshot) {
                    if(snapshot.connectionState == ConnectionState.waiting){
                      return Center(child: CircularProgressIndicator(),);
                    }
                    List<PostinganKasus> cases = snapshot.data!.docs.map((e) => PostinganKasus.fromMap(e.data())).toList();
                    if(cases.isEmpty) return Container(
                        height: 300,
                        child: Center(child: Text('Pengguna ini tidak memposting kasus apapun', style: TextStyle(color: Colors.black),),));
                    else
                    return Column(
                      children: [

                          for(final kasus in cases) PostCard(kasus: kasus, asPost: true, toMapKejahatan: (position){})
                      ],
                    );
                  }
              )
            ],
          ),
        ),
      ),
    );
  }
}