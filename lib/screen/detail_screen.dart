import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/widgets/audio_player.dart';
import 'package:pantau/widgets/custom_video_player.dart';
import 'package:pantau/widgets/toggle_text.dart';
import 'package:pantau/models/place_location.dart';
import 'package:http/http.dart' as http;
import 'package:pantau/widgets/video_player_custom.dart';
import 'package:pantau/widgets/video_widget.dart';
import 'package:video_player/video_player.dart';
class DetailScreen extends StatefulWidget{
  final PostinganKasus kasus;
  final String currentLocation;
  final void Function(PlaceLocation) toMapKejahatan;
  const DetailScreen({super.key, required this.kasus, required this.toMapKejahatan, required this.currentLocation});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _DetailScreenState();
  }
}
class _DetailScreenState extends State<DetailScreen>{

  String caseLocation = '';


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
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCityAndProvinceLocation();
    for(final file in widget.kasus.video){
      print(file);
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Padding(
      padding: const EdgeInsets.only(left: 10, top: 10, bottom: 10),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.kasus.jenisKasus != TipeKasus.LaporanCepat?[
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text(widget.kasus.judul, style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),),
            ),
            Divider(thickness: 3, color: Colors.blue,),

            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text('Bukti', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                color: const Color.fromRGBO(40,65,100,1),
                fontSize: 20), ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if(widget.kasus.gambarUrls.isEmpty) Container(
                    clipBehavior: Clip.antiAlias,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20)
                    ),
                    child: Image.network('https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg',
                    fit:  BoxFit.cover, height: double.infinity,width: double.infinity,),
                  ) else
                          ...widget.kasus.gambarUrls.map((url) =>  Container(
                   width: 150,
                  height: 150,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20)
                            ),
                        clipBehavior: Clip.antiAlias,
                        margin: EdgeInsets.all(5),
                        child: Image.network(url,
                        fit:  BoxFit.cover, height: double.infinity,width: double.infinity,),)).toList()
                            ],
                          ) ,
            ),
            //Divider(thickness: 3, color: Colors.blue,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Text('Waktu dan Lokasi', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(40,65,100,1),
                      fontSize: 20), ),
                ),),
                Flexible(child: TextButton.icon(
                    onPressed: (){
                      final coordinate = widget.kasus.lokasi.split(',');
                      final lat = double.parse(coordinate[0]);
                      final lng = double.parse(coordinate[1]);
                      widget.toMapKejahatan(PlaceLocation(latitude: lat, longitude: lng, address: ''));

                    }, icon: Icon(Icons.map_rounded), label: Text('Buka di Peta')))
              ],
            ),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.blue.shade400
              ),
              child: Wrap(
                direction: Axis.horizontal,
                runSpacing: 10,
                spacing: 10,
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white,),
                        SizedBox(width: 4),
                        Text('${widget.kasus.waktuTerjadinyaKasus.hour}:'
                            ' ${widget.kasus.waktuTerjadinyaKasus.minute}',
                          style: Theme.of(context).textTheme.bodyMedium!.
                          copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white,),
                        SizedBox(width: 4),
                        Text('${DateFormat('dd MMM yyyy').format(widget.kasus.tanggalTerjadinyaKasus)}', style: Theme.of(context).textTheme.bodyMedium!.
                        copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),

                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Colors.white,),
                        SizedBox(width: 4),
                        Text(widget.currentLocation.isEmpty? caseLocation : widget.currentLocation,overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium!.
                        copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),


                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8,bottom: 8, right: 8),
              child: Text('Deskripsi', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 20), ),
            ),
            Container(
              margin: EdgeInsets.only(top: 8,bottom: 8, right: 16),
              child: Text(widget.kasus.deskripsi, textAlign: TextAlign.justify ,style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontFamily: 'Times New Roman' ,fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 16), ),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8, right: 8),
              child: Text('Keterangan', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 20), ),
            ),
            ToggleSwitchWidget(optionsData: {
              'Korban' : {
                'headline': widget.kasus.namaKorban ,
                'content' : widget.kasus.keteranganKorban
              },
              'Kepolisian' : {
                'headline' : 'Kepolisian',
                'content' : ''
              },
              'Tersangka' : {
                'headline' : 'Tersangka',
                'content' : ''
              },
              'Saksi' : {
              'headline' : 'Saksi',
              'content' : ''
            }}),



          ]
          :[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Container(
                  margin: EdgeInsets.only(bottom: 8),
                  child: Text('Waktu dan Lokasi', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                      color: const Color.fromRGBO(40,65,100,1),
                      fontSize: 20), ),
                ),),
                Flexible(child: TextButton.icon(
                    onPressed: (){
                      final coordinate = widget.kasus.lokasi.split(',');
                      final lat = double.parse(coordinate[0]);
                      final lng = double.parse(coordinate[1]);
                      widget.toMapKejahatan(PlaceLocation(latitude: lat, longitude: lng, address: ''));

                    }, icon: Icon(Icons.map_rounded), label: Text('Buka di Peta')))
              ],
            ),

            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue.shade400
              ),
              child: Wrap(
                direction: Axis.horizontal,
                runSpacing: 10,
                spacing: 10,
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.access_time, color: Colors.white,),
                        SizedBox(width: 4),
                        Text('${widget.kasus.waktuTerjadinyaKasus.hour}:'
                            ' ${widget.kasus.waktuTerjadinyaKasus.minute}',
                          style: Theme.of(context).textTheme.bodyMedium!.
                          copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.calendar_today, color: Colors.white,),
                        SizedBox(width: 4),
                        Text('${DateFormat('dd MMM yyyy').format(widget.kasus.tanggalTerjadinyaKasus)}', style: Theme.of(context).textTheme.bodyMedium!.
                        copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),

                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: Colors.white,),
                        SizedBox(width: 4),
                        Text(widget.currentLocation.isEmpty? caseLocation : widget.currentLocation,overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodyMedium!.
                        copyWith(color: Colors.white, fontSize: 16),),
                      ],
                    ),
                  ),


                ],
              ),
            ),

            Container(
              margin: EdgeInsets.only(bottom: 8,top: 8),
              child: Text('Foto', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 20), ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if(widget.kasus.gambarUrls.isEmpty) Container(
                    clipBehavior: Clip.antiAlias,
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Image.network('https://www.generationsforpeace.org/wp-content/uploads/2018/03/empty.jpg',
                      fit:  BoxFit.cover, height: double.infinity,width: double.infinity,),
                  ) else
                    ...widget.kasus.gambarUrls.map((url) =>  Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20)
                      ),
                      clipBehavior: Clip.antiAlias,
                      margin: EdgeInsets.all(5),
                      child: Image.network(url,
                        fit:  BoxFit.cover, height: double.infinity,width: double.infinity,),)).toList()
                ],
              ) ,
            ),
            Container(
              margin: EdgeInsets.only(bottom: 8,top: 8),
              child: Text('Video', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 20), ),
            ),
            widget.kasus.video.isNotEmpty? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child:
              Row(
                children: [
                  for(final file in widget.kasus.video)
                  Container(
                    margin: EdgeInsets.only(right:8),
                      color:Colors.black,
                      width:350,
                      child: VideoPlayerView( url:file, dataSourceType: DataSourceType.network, ))

                ],
              ),
            ):
          Container(height:150, child: Center(child: Text('Tidak ada video', style: TextStyle(color: Colors.black),),)),
            Container(
              margin: EdgeInsets.only(bottom: 8),
              child: Text('Suara', style: Theme.of(context).textTheme.titleLarge!.copyWith(fontWeight: FontWeight.w500,
                  color: const Color.fromRGBO(40,65,100,1),
                  fontSize: 20), ),
            ),
            if(widget.kasus.rekamanSuara.isNotEmpty)
            AudioPlaylistPage(urls: widget.kasus.rekamanSuara)
            else Container(height: 150,child: Center(child: Text('Tidak ada rekaman suara', style: TextStyle(color: Colors.black),),))
          ],
        ),
      ),
    );
  }
}