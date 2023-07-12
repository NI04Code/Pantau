import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:pantau/models/kasus.dart';



import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/detail_post_screen.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/resources/auth.dart';
import 'package:http/http.dart' as http;

class ImageCard extends ConsumerStatefulWidget{
  final PostinganKasus kasus;
  const ImageCard({required this.kasus, super.key, required this.photoProfile});
  final String photoProfile;
  @override
  ConsumerState<ImageCard> createState() {
    // TODO: implement createState
    return _PostCardState();
  }
}

class _PostCardState extends ConsumerState<ImageCard> {


  bool locationFound = false;
  String caseLocation = '';


  Future<void> likePost() async {
    final user = ref.watch(userProvider);
    setState(() {
      if (widget.kasus.upvote.contains(user.uid)) {
        widget.kasus.upvote.remove(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda membatalkan upvote pada kasus ini')));
      }
      else {
        if (widget.kasus.downvote.contains(user.uid)) {
          widget.kasus.downvote.remove(user.uid);
        }
        widget.kasus.upvote.add(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda melakukan upvote pada kasus ini')));
      }
    });
    try {
      await Auth.instance.firebase.collection('posts')
          .doc(widget.kasus.idPost)
          .update(
          {
            'downvote': widget.kasus.downvote,
            'upvote': widget.kasus.upvote
          }
      );
    }
    catch (error) {

    }
  }

  getCityAndProvinceLocation() async {
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
      if (widget.kasus.downvote.contains(user.uid)) {
        widget.kasus.downvote.remove(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda membatalkan downvote pada kasus ini')));
      }
      else {
        if (widget.kasus.upvote.contains(user.uid)) {
          widget.kasus.upvote.remove(user.uid);
        }
        widget.kasus.downvote.add(user.uid);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Anda melakukan downvote pada kasus ini')));
      }
    });
    try {
      await Auth.instance.firebase.collection('posts')
          .doc(widget.kasus.idPost)
          .update(
          {
            'downvote': widget.kasus.downvote,
            'upvote': widget.kasus.upvote
          }
      );
    }
    catch (error) {

    }
  }

  void initState() {
    super.initState();
    getCityAndProvinceLocation();
  }

  @override
  Widget build(BuildContext context) {
    //  final likesDislikes = ref.watch(widget.kasus.likeDislikeProvider!);
    final user = ref.watch(userProvider);
    // TODO: implement build
    return Container(
      margin: EdgeInsets.only(bottom: 24),

      child: Column(
        children: [
          InkWell(
            onTap: () {

            },
            child: Stack(
              children: [
                
               if(widget.kasus.gambarUrls.isNotEmpty || widget.kasus.thumbnail.isNotEmpty) CarouselWidget(imageUrls: widget.kasus.thumbnail.trim().isEmpty? widget.kasus.gambarUrls 
                : [widget.kasus.thumbnail, ...widget.kasus.gambarUrls]) 
                else CarouselWidget(imageUrls: ['https://www.namepros.com/attachments/empty-png.89209/']),
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
                          '${DateFormat('dd MMM yyyy').format(widget.kasus
                              .tanggalTerjadinyaKasus)}',
                          // Teks tanggal yang ditambahkan
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
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
                                    maxWidth: MediaQuery
                                        .of(context)
                                        .size
                                        .width * 0.28
                                ),
                                child: Text(
                                  (!locationFound ? ' loading' : caseLocation),
                                  maxLines: 2,
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
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: widget.kasus.jenisKasus == TipeKasus.LaporanCepat? Color.fromRGBO(40,65,100,1):Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(widget.kasus.jenisKasus == TipeKasus.LaporanCepat? 'Laporan Cepat' :
                                widget.kasus.jenisKasus.name,
                                // Teks tanggal yang ditambahkan
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.all(12),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.red.shade700,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Belum diverifikasi',
                                // Teks tanggal yang ditambahkan
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 14),
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
                                        child: Row(
                                          children: [
                                           widget.photoProfile.isEmpty? CircleAvatar(radius: 16, child:
                                             Icon(Icons.person_rounded), backgroundColor: Colors.grey,):
                                            CircleAvatar(radius: 16, backgroundImage: NetworkImage(widget.photoProfile),),
                                            SizedBox(
                                              width: 16 ,
                                            ),
                                            Text(
                                              widget.kasus.username,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 2,
                                              style: Theme
                                                  .of(context)
                                                  .textTheme
                                                  .headlineSmall!
                                                  .copyWith(color: Colors.white,
                                                  fontSize: 20),
                                            ),
                                          ],
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          likePost();
                                          // Aksi yang dijalankan ketika tombol upvote ditekan
                                        },
                                        style: TextButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            !widget.kasus.upvote.contains(
                                                user.uid)
                                                ? Icon(
                                                Icons.arrow_upward_rounded,
                                                size: 36, color: Colors.white)
                                                : Icon(
                                                Icons.arrow_upward_rounded,
                                                size: 36, color: Colors.blue
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(widget.kasus.upvote.length
                                                .toString(), style: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                        ),
                                        child: Row(
                                          children: [
                                            !widget.kasus.downvote.contains(
                                                user.uid)
                                                ? Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 36, color: Colors.white,)
                                                : Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 36, color: Colors.blue,),
                                            SizedBox(width: 4.0),
                                            Text(widget.kasus.downvote.length
                                                .toString(), style: Theme
                                                .of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: Colors.white
                                            ),),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )),
                      ],
                    )
                )
              ],
            ),
          ),
          
            
        ],
      ),
    );
  }
}


class CarouselWidget extends StatefulWidget {
  final List<String> imageUrls;

  CarouselWidget({required this.imageUrls});

  @override
  _CarouselWidgetState createState() => _CarouselWidgetState();
}

class _CarouselWidgetState extends State<CarouselWidget> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider.builder(
          itemCount: widget.imageUrls.length,
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final imageUrl = widget.imageUrls[index];
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
              ),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          },
        ),
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: widget.imageUrls.map((imageUrl) {
              int index = widget.imageUrls.indexOf(imageUrl);
              return Container(
                width: 8.0,
                height: 8.0,
                margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == index ? Colors.blue : Colors.grey,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

