import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/place_location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';



import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pantau/models/kasus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pantau/models/place_location.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pantau/models/place_location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:pantau/screen/create_post_screen.dart';
import 'package:pantau/screen/detail_post_screen.dart';





class MapKejahatan extends StatefulWidget{
  List<PostinganKasus> listKasus;
  LatLng? markerPost;
  final void Function(PlaceLocation) toMapKejahatan;

  MapKejahatan({super.key,
    this.location = const PlaceLocation(
        latitude: -6.270565,
        longitude: 106.828737,
        address: ''
    ) ,
    required this.toMapKejahatan,
    this.markerPost = null,
    required this.listKasus,
    this.isSelecting = true
  });
  final PlaceLocation location;
  final bool isSelecting;
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MapScreenState();
  }

}

class _MapScreenState extends State<MapKejahatan>{

  LatLng?  pickedLocation;
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  final String myMapsAPIKey = 'AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg';
  String location = "Cari Kasus Berdasarkan Lokasi";
  List<Marker> markers = [];
  Map<String, String> casesLocationMapping = {};
  Map<String, LatLng> coordinateMapping = {};
  bool close = false;


  fillMarkers(List<PostinganKasus> list) async {
    for (int i = 0; i < list.length; i++) {
      final coordinates = list[i].lokasi.split(',');
      final lat = double.parse(coordinates[0]);
      final lng = double.parse(coordinates[1]);
      BitmapDescriptor bitmapDescriptor = await
      BitmapDescriptor.fromAssetImage(ImageConfiguration(),
          list[i].jenisKasus == TipeKasus.LaporanCepat ? 'asset/lapor-cepat.png'
              : 'asset/lapor.png');
      LatLng targetCoordinate = LatLng(lat, lng);
      coordinateMapping[list[i].idPost]= targetCoordinate;
      casesLocationMapping[list[i].idPost] = await getAddressFromLatLng(targetCoordinate);
      Marker marker = Marker(markerId: MarkerId(list[i].idPost),
          onTap: (){
            showModalBottomSheet(
              context: context,
              builder: (BuildContext context) {
                // Kembalikan widget yang ingin ditampilkan dalam BottomSheet
                return SizedBox(
                    height: 1 * MediaQuery.of(context).size.height,
                    child: DetailPostScreen(profileUrl:'',toMapkejahatan:widget.toMapKejahatan,kasus: list[i], currentLocation:  '',));
              },
            );
          },
          position: LatLng(lat, lng),
          icon: bitmapDescriptor,
          infoWindow: InfoWindow(title: calculateTimeDifference(
              list[i].tanggalPemostingan, DateTime.now())));
      markers.add(marker);
    }
  }
  String calculateTimeDifference(DateTime startDate, DateTime endDate) {
    Duration difference = endDate.difference(startDate);
    print(difference);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else if (difference.inDays < 30) {
      int weeks = (difference.inDays / 7).floor();
      return '${weeks} minggu yang lalu';
    } else {
      int months = (difference.inDays / 30).floor();
      return '${months} bulan yang lalu';
    }
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fillMarkers(widget.listKasus);
  }
  Future<String> getAddressFromLatLng(LatLng latLng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks != null && placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String address = '${placemark.name ?? ''}, ${placemark.subThoroughfare ?? ''}'
            ' ${placemark.thoroughfare ?? ''}, ${placemark.subLocality ?? ''}, ${placemark.locality ?? ''}, ${placemark.subAdministrativeArea ?? ''} ${placemark.administrativeArea ?? ''}, ${placemark.postalCode ?? ''}, ${placemark.country ?? ''}';
        return address;
      }
    } catch (e) {
      print('Error: $e');
    }
    return '';
  }
  closeSearchBar(){
    close = true;
  }

  void updateCamera(LatLng coordinate){
    mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: coordinate, zoom: 16)));
  }




  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Peta Kasus',
          style: Theme.of(context).
          textTheme.headlineSmall!.
          copyWith(color: Colors.black), ),

      ),
      body: Stack(
        alignment:  Alignment.center,
        children: [
          GoogleMap(
            onMapCreated: (controller){
              setState(() {
                mapController = controller;
              });
            },
            onTap: (position){
              setState(() {
                close = true;
                pickedLocation = position;
              });
            },
            initialCameraPosition: CameraPosition(
              target: widget.markerPost == null?  LatLng(widget.location.latitude,
                  widget.location.longitude) : widget.markerPost!,
              zoom: 16,
            ),
            markers:{
              ...markers.toSet(),
              Marker(markerId:
              const MarkerId('user',),
                  position: pickedLocation != null? pickedLocation! :  LatLng(
                      widget.location.latitude,
                      widget.location.longitude
                  ))
            },
          ),

          Positioned(top:10,child: AutocompleteTextField(coordinatesMapping:coordinateMapping,changePosition:updateCamera,cases: widget.listKasus, casesMapping: casesLocationMapping,close:  close,))
        ],
      ),
    );
  }
}


class AutocompleteTextField extends StatefulWidget {
  final List<PostinganKasus> cases;
  final Map<String, String> casesMapping;
  final Map<String, LatLng> coordinatesMapping;

  final void Function(LatLng) changePosition;
  bool close;
  AutocompleteTextField({required this.cases, required this.casesMapping, required this.changePosition, required this.close, required this.coordinatesMapping});
  @override
  _AutocompleteTextFieldState createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final TextEditingController _controller = TextEditingController();
  GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: 'AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg');

  List<Prediction> _predictions = [];
  List<PostinganKasus> _filteredPosts = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onLocationChanged(String input) async {
    if (input.isNotEmpty) {
      PlacesAutocompleteResponse response = await _places.autocomplete(
        input,
        language: 'id',
      );

      setState(() {
        _predictions = response.predictions;
        _filteredPosts = widget.cases.where((kasus) => widget.casesMapping[kasus.idPost]!.toLowerCase()!.contains(input.trim().toLowerCase())).toList();
      });
    } else {
      setState(() {
        _predictions = [];
        _filteredPosts = [];
      });
    }
  }

  Future<void> _selectPlace(Prediction prediction) async {
    PlacesDetailsResponse details = await _places.getDetailsByPlaceId(prediction.placeId!);
    double lat = details.result.geometry!.location!.lat;
    double lng = details.result.geometry!.location!.lng;
    setState(() {
      widget.close = true;
    });
    widget.changePosition(LatLng(lat, lng));
  }
  void selectCaseLocation(PostinganKasus kasusSelected){
    final coordinate = widget.coordinatesMapping[kasusSelected.idPost];
    setState(() {
      widget.close = true;
    });
    widget.changePosition(coordinate?? LatLng(0,0));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
      decoration: BoxDecoration(
          borderRadius:  BorderRadius.circular(10),
          color: Colors.blue.shade500
      ),

      width:  MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            onChanged: (value) {
              widget.close = false;
              _onLocationChanged(value);
            },
            decoration: InputDecoration(
              hintText: 'Cari kasus berdasarkan lokasi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 3.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.blue.shade500, width: 3.0),
              ),
              suffixIcon: IconButton(icon: Icon(Icons.search, color:  Colors.blue.shade500,),onPressed: (){
                widget.close = false;
                _onLocationChanged(_controller.text);
              },),
              fillColor: Colors.grey[200],
              filled: true,
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if(_filteredPosts.isNotEmpty && _controller.text.isNotEmpty && !widget.close)
                    for(final kasus in _filteredPosts) ListTile(onTap:(){
                      selectCaseLocation(kasus);
                    },leading:CircleAvatar(backgroundImage: kasus.jenisKasus == TipeKasus.LaporanCepat? AssetImage('asset/lapor-cepat.png'):
                    AssetImage('asset/lapor.png'),),title:
                    Text(kasus.jenisKasus ==
                        TipeKasus.LaporanCepat? 'Laporan Cepat':kasus.judul, style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),
                        subtitle: Text(widget.casesMapping[kasus.idPost]?? ' ', style: TextStyle(color: Colors.grey.shade300, fontWeight: FontWeight.w300),overflow: TextOverflow.ellipsis, maxLines: 2,)
                    ),

                  if(_predictions.isNotEmpty && _controller.text.isNotEmpty & !widget.close)
                    for(final prediction in _predictions) ListTile(onTap:(){
                      _selectPlace(prediction);
                    },title:
                    Text(prediction.description!, style:  TextStyle(color: Colors.white, fontWeight: FontWeight.w700),),),

                ],
              ),
            ),
          )



        ],
      ),
    );
  }
}