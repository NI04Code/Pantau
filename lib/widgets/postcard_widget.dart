

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/detail_post_screen.dart';
import 'package:pantau/screen/homepage.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/resources/auth.dart';
import 'package:http/http.dart' as http;
import 'package:pantau/widgets/expandable_text.dart';
import 'package:pantau/models/user.dart';

class PostCard extends ConsumerStatefulWidget{
  final PostinganKasus kasus;
  const PostCard({required this.kasus, super.key, required this.asPost, required this.toMapKejahatan});
  final bool asPost;

  final void Function(PlaceLocation) toMapKejahatan;
  @override
  ConsumerState<PostCard> createState() {
    // TODO: implement createState
    return _PostCardState();
  }
}

class _PostCardState extends ConsumerState<PostCard>{


  bool locationFound = false;
  String caseLocation = '';
  String? photoProfile;


  Future<void> likePost() async{
    final user = ref.watch(userProvider);
    setState(() {
      if(widget.kasus.upvote.contains(user.uid)){
        widget.kasus.upvote.remove(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda membatalkan upvote pada kasus ini')));

      }
      else{
        if(widget.kasus.downvote.contains(user.uid)){
          widget.kasus.downvote.remove(user.uid);
        }
        widget.kasus.upvote.add(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda melakukan upvote pada kasus ini')));
      }
    });
    try{
      await Auth.instance.firebase.collection('posts').doc(widget.kasus.idPost).update(
          {
            'downvote' : widget.kasus.downvote,
            'upvote' : widget.kasus.upvote
          }
      );

    }
    catch(error){

    }
}
void getPhotoProfile() async{
    final raw=await FirebaseFirestore.instance.collection('users').doc(widget.kasus.uid).get();
    User sender = User.buildUser(raw);
    photoProfile = sender.photoUrl;
}
 getCityAndProvinceLocation() async{
    List<String> coordinate = widget.kasus.lokasi.split(',');
    double latitude = double.parse(coordinate.first);
    double longitude = double.parse(coordinate.last);
   final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg');
   final response = await http.get(url);
   final resData = jsonDecode(response.body);
   print(resData['results'][4]['address_components'][3]['short_name']);
   final kota = resData['results'][4]['address_components'][3]['short_name'];
   final provinsi = resData['results'][4]['address_components'][4]['short_name'];
   setState(() {
     caseLocation = '$kota, $provinsi';
     locationFound = true;
   });
  }





Future<void> dislikePost() async {
  final user = ref.watch(userProvider);
  setState(() {
    if(widget.kasus.downvote.contains(user.uid)){
      widget.kasus.downvote.remove(user.uid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Anda membatalkan downvote pada kasus ini')));

    }
    else{
      if(widget.kasus.upvote.contains(user.uid)){
        widget.kasus.upvote.remove(user.uid);
      }
      widget.kasus.downvote.add(user.uid);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue,
          content: Text('Anda melakukan downvote pada kasus ini')));
    }
  });
  try{
    await Auth.instance.firebase.collection('posts').doc(widget.kasus.idPost).update(
        {
          'downvote' : widget.kasus.downvote,
          'upvote' : widget.kasus.upvote
        }
    );

  }
  catch(error){

  }
}
  void initState() {
    super.initState();
    getCityAndProvinceLocation();
    getPhotoProfile();
  }
  @override
  Widget build(BuildContext context) {
  //  final likesDislikes = ref.watch(widget.kasus.likeDislikeProvider!);
    final user = ref.watch(userProvider);
    // TODO: implement build
    return Container(
      //margin: EdgeInsets.only(bottom: 24),

      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: (){

            },
            child: Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4/3,
                  child: Image(

                      fit: BoxFit.cover,
                      width: double.infinity,
                      //height: 338,//MediaQuery.of(context).size.height * 0.4,
                      //placeholder: MemoryImage(kTransparentImage),
                      image: NetworkImage(widget.kasus.thumbnail == ''? 'https://thenounproject.com/api/private/icons/2879926/edit/?backgroundShape=SQUARE&backgroundShapeColor=%23000000&backgroundShapeOpacity=0&exportSize=752&flipX=false&flipY=false&foregroundColor=%23000000&foregroundOpacity=1&imageFormat=png&rotation=0':widget.kasus.thumbnail
                      )
                  ),
                ),
                // T A N G G A L   K A S U S
                Positioned(
                  top: 8,
                  left: 8,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8.6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                         '${DateFormat('dd MMM yyyy').format(widget.kasus.tanggalTerjadinyaKasus)}', // Teks tanggal yang ditambahkan
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize:  16
                          ),
                        ),
                      ),
            SizedBox(width: 8,),
            Container(
              padding: const EdgeInsets.all(6),

              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.red,),
                  Container(

                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.28
                    ),
                    child: Text(
                        (! locationFound ?' loading' : caseLocation),maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      // overflow: TextOverflow.ellipsis,// Teks tanggal yang ditambahkan
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ))
                    ],
                  ),
                ),




                Positioned(
                  top: 6,
                  right: 4,
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.share,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          // Aksi yang dijalankan ketika tombol Share ditekan
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.more_vert_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {


                          // Aksi yang dijalankan ketika tombol Report ditekan
                        },
                      ),
                    ],
                  ),
                ),




                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding:  const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.kasus.jenisKasus == TipeKasus.LaporanCepat?Color.fromRGBO(40,65,100,1) : Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(widget.kasus.jenisKasus == TipeKasus.LaporanCepat? 'Laporan Cepat':
                                widget.kasus.jenisKasus.name, // Teks tanggal yang ditambahkan
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:  16
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding:  const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Belum diverifikasi', // Teks tanggal yang ditambahkan
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize:  16
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(vertical: 6,horizontal: 14),
                            color: Colors.black26,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          widget.kasus.judul, overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.white, fontSize: 16),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          likePost();
                                          // Aksi yang dijalankan ketika tombol upvote ditekan
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            !widget.kasus.upvote.contains(user.uid)?Icon(Icons.arrow_upward_rounded, size: 36, color:  Colors.white) : Icon(Icons.arrow_upward_rounded,size: 36, color:  Colors.blue
                                            ) ,
                                            SizedBox(width: 4.0),
                                            Text(widget.kasus.upvote.length.toString(),style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                            )),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          dislikePost();
                                          // Aksi yang dijalankan ketika tombol downvote ditekan
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            !widget.kasus.downvote.contains(user.uid)?Icon(Icons.arrow_downward_rounded, size: 36, color: Colors.white,) : Icon(Icons.arrow_downward_rounded, size: 36, color: Colors.blue,),
                                            SizedBox(width: 4.0),
                                            Text(widget.kasus.downvote.length.toString(), style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ButtonBar(
                                  alignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                        onPressed: () {
                                          if(! widget.kasus.diikuti.contains(user.uid)){
                                            tambahkanIkutiKasus(widget.kasus, user.uid);
                                          }else{
                                            batalIkutiKasus(widget.kasus, user.uid);
                                          }
                                          // Aksi yang dijalankan ketika tombol follow ditekan
                                        },
                                        child: Column(
                                          children: [
                                            SizedBox(height: 2,),
                                            Text(widget.kasus.diikuti.contains(user.uid)?' Diikuti ':' + Ikuti ', style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                                fontSize: 22,
                                                fontWeight: FontWeight.w100,
                                                color: Colors.white
                                            ),),
                                            SizedBox(height: 3,)
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(20),
                                            ))
                                    ),
                                    OutlinedButton(
                                      onPressed: () {
                                        Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                                          return DetailPostScreen(profileUrl: photoProfile == null? '':photoProfile!,currentLocation: caseLocation, toMapkejahatan: widget.toMapKejahatan,kasus: widget.kasus);
                                        }));
                                        // Aksi yang dijalankan ketika tombol See Details ditekan
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        side: BorderSide(
                                          width: 2.5, // Menentukan ketebalan border
                                          color: Colors.blue.shade100, // Menentukan warna border
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          SizedBox(height: 2,),
                                          Text('Lihat Selengkapnya', style:  Theme.of(context).textTheme.headlineMedium!.copyWith(
                                              fontSize: 22,
                                              fontWeight: FontWeight.w100,
                                              color: Colors.blue.shade100
                                          ),),
                                          SizedBox(height: 3),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      ],
                    )
                )],
            ),
          ),
          if(widget.asPost)
          Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 12, right: 12, top: 12, bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(' Diposting oleh ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w100),),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                photoProfile == null || photoProfile!.isEmpty?CircleAvatar(
                                    radius: 16,
                                    child: Icon(Icons.person_rounded,),
                                  backgroundColor: Colors.grey,
                                ) : CircleAvatar(
                                  radius: 16,
                                    backgroundImage: NetworkImage(photoProfile!),
                                ),
                                SizedBox(width:  8,),
                                Text(widget.kasus.username, style: TextStyle(color: Colors.black),)
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: Align(
                      alignment: Alignment.bottomRight,
                      child: Text(('${DateFormat.Hm().format(widget.kasus.tanggalPemostingan)} \n'
                          '${DateFormat('dd MMM yyyy').format(widget.kasus.tanggalPemostingan)}'), textAlign: TextAlign.right, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey),),
                    ))
                  ],
                ),
              ),
              Container(
                margin:  EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(
                                  ' Deskripsi',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Colors.black
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(child: Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton.icon(onPressed: (){
                        final coordinate = widget.kasus.lokasi.split(',');
                        final lat = double.parse(coordinate[0]);
                        final lng = double.parse(coordinate[1]);
                        widget.toMapKejahatan(PlaceLocation(latitude: lat, longitude: lng, address: ''));
    }, icon: const Icon(Icons.map, color: Colors.red,), label:
    Text('Kunjungi di peta kejahatan', style:
    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),)
    ),),
                    )
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ExpandableText(text: widget.kasus.deskripsi,maxLines: 4)
              ),
              SizedBox(height: 24,)
            ],
          )
        ],
      ),
    );
  }
}