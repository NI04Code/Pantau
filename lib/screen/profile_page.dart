import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pantau/models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau/resources/auth.dart';
import 'dart:io';

class ProfilePage extends ConsumerWidget {
  User user;

  ProfilePage({required this.user});



  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    String? url;

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      url = await Auth.instance.uploadImageToStorage(
          childName: 'profile', file: file.readAsBytesSync(), isPost: false);
    }
    if (url != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'photo_url': url
          });
    }
  }

  Future<void> _pickImageFromCamera() async {
    final picker = ImagePicker();
    String? url;
    final pickedImage = await picker.pickImage(source: ImageSource.camera);

    if (pickedImage != null) {
      final file = File(pickedImage.path);
      url = await Auth.instance.uploadImageToStorage(
          childName: 'profile', file: file.readAsBytesSync(), isPost: false);
    }
    if (url != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
          {
            'photo_url': url
          });
    }
  }

    Future<void> _showImageSourceDialog(BuildContext context) async {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Ganti Foto Profil', style: TextStyle(color: Colors.black),),
            content: SingleChildScrollView(
              child: ListBody(
                children: [
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(Icons.photo_library),
                      title: Text(
                        'Ambil dari galeri', style: TextStyle(color: Colors
                          .black),),
                    ),
                    onTap: () {
                      _pickImageFromGallery();
                      Navigator.of(context).pop();
                    },
                  ),
                  GestureDetector(
                    child: ListTile(
                      leading: Icon(Icons.camera_alt),
                      title: Text(
                        'Ambil dari kamera', style: TextStyle(color: Colors
                          .black),),
                    ),
                    onTap: () {
                      _pickImageFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
   
      return Scaffold(

        body: SafeArea(
          child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('users').where(
                  'uid', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return Center(child: CircularProgressIndicator(),); else {
                  List<User> users = snapshot.data!.docs!.map((e) =>
                      User.buildUser(e)).toList();
                  user = users.first;
                  print(users.first.convertJSON());
                  return SingleChildScrollView(
                    child: Column(
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
                                Stack(
                                  children: [
                                    Container(

                                      child: CircleAvatar(
                                          radius: 64,
                                          backgroundImage: NetworkImage(
                                              user.photoUrl!)
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: IconButton(onPressed: () {
                                          _showImageSourceDialog(context);
                                        },
                                          icon: Icon(
                                            Icons.add_circle, size: 36,),))
                                  ],
                                ) else
                                Stack(
                                  children: [
                                    Container(
                                      //color: Colors.red,
                                      child: CircleAvatar(
                                        radius: 64,
                                        child: Icon(Icons.person_rounded,
                                          color: Colors.white, size: 72,),
                                        backgroundColor: Colors.grey,
                                      ),
                                    ),
                                    Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: IconButton(onPressed: () {
                                          _showImageSourceDialog(context);
                                        },
                                          icon: Icon(
                                            Icons.add_circle, size: 36,),))
                                  ],
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
                            ],
                          ),
                        )
                        ,
                        ListTile(
                          title: Text('Profil dan Akun', style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),),
                          leading: Icon(
                            Icons.person_rounded, size: 48, color: Colors
                              .blue,),
                        ),
                        Divider(color: Colors.blue, thickness: 2,),
                        ListTile(
                          title: Text('Keamanan', style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),),
                          leading: Icon(Icons.settings, size: 48, color: Colors
                              .blue,),
                        ),
                        Divider(color: Colors.blue, thickness: 2,),
                        ListTile(
                          title: Text('Bantuan ', style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),),
                          leading: Icon(Icons.help, size: 48, color: Colors
                              .blue,),
                        ),
                        Divider(color: Colors.blue, thickness: 2,),
                        ListTile(
                          title: Text('Kebijakan dan Privasi', style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),),
                          leading: Icon(
                            Icons.privacy_tip_rounded, size: 48, color: Colors
                              .blue,),
                        ),
                        Divider(color: Colors.blue, thickness: 2,),
                        Container(height: 50,
                          child: Align(
                            alignment: Alignment.center,
                            child: Text('Pantau 2023',
                              style: TextStyle(color: Colors.black),),),)
                      ],
                    ),
                  );
                }
              }
          ),
        ),
      );
    }
  }
