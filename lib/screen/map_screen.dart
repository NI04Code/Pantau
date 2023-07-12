import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pantau/models/place_location.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';

class MapScreen extends StatefulWidget{
  const MapScreen({super.key,
    this.location = const PlaceLocation(
      latitude: -6.270565,
      longitude: 106.828737,
      address: ''
    ) ,
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

class _MapScreenState extends State<MapScreen>{

  LatLng?  pickedLocation;
  GoogleMapController? mapController;
  CameraPosition? cameraPosition;
  final String myMapsAPIKey = 'AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg';
  String location = "Search Location";


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.isSelecting?
          'Cari Lokasi' : 'Lokasi Anda Sekarang',
          style: Theme.of(context).
          textTheme.headlineSmall!.
          copyWith(color: Colors.black), ),
        actions: [

          if(widget.isSelecting) IconButton(icon:
          Icon(Icons.save, color: Colors.black,), onPressed: (){
            Navigator.of(context).pop(pickedLocation);

          },),

        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller){
              setState(() {
                mapController = controller;
              });
            },
            onTap: (position){
              setState(() {
                pickedLocation = position;
              });
            },
            initialCameraPosition: CameraPosition(
              target: LatLng(widget.location.latitude,
              widget.location.longitude),
              zoom: 16,
            ),
            markers:( pickedLocation == null && widget.isSelecting)? {} : {
              Marker(markerId:
              const MarkerId('user',),
              position: pickedLocation != null? pickedLocation! :  LatLng(
                widget.location.latitude,
                widget.location.longitude
              ))
            },
          ),
          Positioned(  //search input bar
              top:10,
              child: InkWell(
                  onTap: () async {
                    var place = await PlacesAutocomplete.show(
                        context: context,
                        apiKey: myMapsAPIKey,
                        mode: Mode.overlay,
                        types: [],
                        strictbounds: false,
                        components: [Component(Component.country, 'id')],
                        //google_map_webservice package
                        onError: (err){
                          print(err);
                        }
                    );

                    if(place != null){
                      setState(() {
                        location = place.description.toString();
                      });

                      //form google_maps_webservice package
                      final plist = GoogleMapsPlaces(apiKey:myMapsAPIKey,
                        apiHeaders: await GoogleApiHeaders().getHeaders(),
                        //from google_api_headers package
                      );
                      String placeid = place.placeId ?? "0";
                      final detail = await plist.getDetailsByPlaceId(placeid);
                      final geometry = detail.result.geometry!;
                      final lat = geometry.location.lat;
                      final lang = geometry.location.lng;
                      setState(() {
                        pickedLocation = LatLng(lat, lang);
                      });


                      //move map camera to selected place with animation
                      mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: pickedLocation!, zoom: 16)));
                    }
                  },
                  child:Padding(
                    padding: EdgeInsets.all(15),
                    child: Card(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          width: MediaQuery.of(context).size.width - 40,
                          child: ListTile(
                            title:Text(location, style: TextStyle(fontSize: 18),),
                            trailing: Icon(Icons.search),
                            dense: true,
                          )
                      ),
                    ),
                  )
              )
          )
        ],
      ),

    );
  }
}