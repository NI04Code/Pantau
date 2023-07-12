
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/screen/map_screen.dart';
import 'package:pantau/screen/create_post_screen.dart';

class LocationWidget extends ConsumerStatefulWidget{

  final Function(PlaceLocation location) onSelected;
  const LocationWidget({super.key, required this.onSelected});
  @override
  ConsumerState<LocationWidget> createState() {
    // TODO: implement createState
    return _LocationWidgetState();
  }
}
class _LocationWidgetState extends ConsumerState<LocationWidget>{
  bool _gettingLocation = false;
  PlaceLocation? pickedLocation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();


  }
  void savePlace(double latitude, double longitude) async{
    final url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg');
    final response = await http.get(url);
    final resData = jsonDecode(response.body);
    final address = resData['results'][0]['formatted_address'];
    setState(() {
      pickedLocation = PlaceLocation
        (latitude: latitude,
          longitude: longitude,
          address: address);
      _gettingLocation = false;
      ref.read(locationRemember.notifier).state = pickedLocation;
    });
    widget.onSelected(pickedLocation!);

  }
  _getCurrentLocation() async {
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _gettingLocation = true;
    });
    _locationData = await location.getLocation();
    final lat = _locationData.latitude;
    final lng = _locationData.longitude;
    if(lat == null || lng == null){
      return;
    }
    savePlace(lat, lng);
  }

  String get locationImage{
    if(pickedLocation == null) {
      return '';
    }
    final lat = pickedLocation!.latitude;
    final lng = pickedLocation!.longitude;

    return
        'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg';
  }

  void selectOnMapToChange() async{
    final pickedLatLng = await Navigator.push<LatLng>(context, MaterialPageRoute(builder: (ctx){
      return pickedLocation == null? const MapScreen() : MapScreen(location: pickedLocation!,);


    }));
    if(pickedLatLng == null){
      return;
    }
    savePlace(pickedLatLng.latitude, pickedLatLng.longitude);
  }
  @override
  Widget build(BuildContext context) {
   pickedLocation = ref.watch(locationRemember);
   if(pickedLocation == null){
     _getCurrentLocation();
   }
   ;
   // if(potentialLocation != null) pickedLocation = potentialLocation;

    Widget previewContent = const Text('Lokasi dinonaktifkan oleh user', style:
    TextStyle(color: Colors.red),);
    if(pickedLocation != null){
      previewContent = Image.network(locationImage, fit: BoxFit.cover, width: double.infinity, height: double.infinity,);
    }
    if(_gettingLocation){
      previewContent = CircularProgressIndicator(color: Colors.blue,);
    }


    // TODO: implement build
    return Column(
      mainAxisSize:  MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: (){
            Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
              return MapScreen(isSelecting: false, location: pickedLocation!,);
            }));
          },
          child: Container(
            height: 170,
            margin: EdgeInsets.symmetric(vertical: 10),
            width:  double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: Colors.red,
              )
            ),
            child: previewContent,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TextButton.icon(onPressed: (){
              _getCurrentLocation();
            }, icon: const
            Icon(Icons.location_on, color: Colors.red,), label: Text('Dapatkan lokasi saat ini', style:
            Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),)),
            TextButton.icon(onPressed: (){
                  selectOnMapToChange();
            }, icon: const Icon(Icons.map, color: Colors.black,), label:
    Text('Atur lokasi di peta', style:
    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.black),)
            )],
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.indigoAccent,
            borderRadius: BorderRadius.circular(10),
          ),
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Text( pickedLocation == null? 'Tidak ada' :
            'Lokasi Terpilih: ${pickedLocation!.address}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        )

      ],
    );
  }
}