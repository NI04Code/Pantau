



import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/like_dislike.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/provider/like_dislike_provider.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/map_kejahatan_screen.dart';
import 'package:pantau/screen/map_screen.dart';
import 'package:pantau/screen/quick_report_page.dart';
import 'package:pantau/screen/search_user_case.dart';
import 'package:pantau/widgets/carousel.dart';
import 'package:pantau/widgets/comment_toggle_sorting.dart';
import 'package:pantau/widgets/postcard_widget.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:pantau/models/user.dart';


const googleAPIKey = 'AIzaSyAyNmQUW-2I82TuN453BTt1vaiRf2A2pFg';
enum SortingKasus{
  Terpopuler,
  KasusTerbaru,
  KasusTerlama,
  KirimanTerbaru,
  KirimanTerlama,
  Terdekat,
}
enum Waktu{
  HariIni,
  MingguIni,
  BulanIni,
  Semua
}
final locationProvider = StateProvider<LocationData?>((ref) => null);

void tambahkanIkutiKasus(PostinganKasus kasus, String uid) async{
  await FirebaseFirestore.instance.collection('posts').doc(kasus.idPost).update({
    'diikuti': FieldValue.arrayUnion([uid])
  });
}
void batalIkutiKasus(PostinganKasus kasus, String uid) async{
  await FirebaseFirestore.instance.collection('posts').doc(kasus.idPost).update(
    {
      'diikuti':FieldValue.arrayRemove([uid])
    }
  );
}


final today = DateTime.now();
final startDayOfMonth = DateTime(today.year, today.month, 1);
final startOfWeek = today.subtract(Duration(days: today.weekday - 1));

final Map<SortingKasus, int Function(PostinganKasus, PostinganKasus)> sortFunction ={
  SortingKasus.Terpopuler : (a,b) => (b.upvote.length - b.downvote.length).compareTo(a.upvote.length - a.downvote.length),
  SortingKasus.KasusTerbaru : (a,b) => (b.tanggalTerjadinyaKasus.compareTo(a.tanggalTerjadinyaKasus)),
  SortingKasus.KasusTerlama : (a,b) => a.tanggalTerjadinyaKasus.compareTo(b.tanggalTerjadinyaKasus),
  SortingKasus.KirimanTerbaru : (a,b)=> b.tanggalPemostingan.compareTo(a.tanggalPemostingan),
  SortingKasus.KirimanTerlama : (a,b)=> a.tanggalPemostingan.compareTo(b.tanggalPemostingan),
};

double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
  const int radiusOfEarth = 6371; // Radius Bumi dalam kilometer

  double latDistance = degreesToRadians(lat2 - lat1);
  double lonDistance = degreesToRadians(lon2 - lon1);

  double a = sin(latDistance / 2) * sin(latDistance / 2) +
      cos(degreesToRadians(lat1)) * cos(degreesToRadians(lat2)) * sin(lonDistance / 2) * sin(lonDistance / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distance = radiusOfEarth * c;

  return distance;
}

double degreesToRadians(double degrees) {
  return degrees * pi / 180;
}

class HomeScreen extends ConsumerStatefulWidget{
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _HomeScreenState();
  }
}
class _HomeScreenState extends ConsumerState<HomeScreen>{
  DateTime? dateUpperBound;
  DateTime? dateLowerBound;
  SortingKasus sortingSelected = SortingKasus.KirimanTerbaru;
  TipeKasus typeSelected = TipeKasus.SemuaKategori;
  Waktu timeSelected = Waktu.Semua;
  LocationData? currentLocation;
  Location? _location;
  final List<Waktu> time = [Waktu.Semua, Waktu.HariIni, Waktu.MingguIni, Waktu.BulanIni];
  int initialIndex = 0;
  List<PostinganKasus> listKasus = [];
  void fetchUser()async{
    final result = await FirebaseFirestore.instance.collection('users').get();
    ref.read(userListProvider.notifier).setUsers(result.docs.map((e) => User.buildUser(e)).toList());
  }

  @override
  void initState() {
    fetchUser();

    // TODO: implement initState
    super.initState();
    _location = Location();
    _location!.onLocationChanged.listen((event) {
      currentLocation = event;
    });
    getCurrentLocation();
    if(currentLocation != null){
      print('here');
      ref.read(locationProvider.notifier).state = currentLocation;
      print(currentLocation);
    }


  }
  void getCurrentLocation() async{
    currentLocation = await _location!.getLocation();
  }


  
  void selectInitialDate() async{
    final DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
    return Theme(
    data: ThemeData.dark(),
    child: child!,
    );
    },);
    
    setState(() {
      dateLowerBound = pickedDate;
      print(dateLowerBound);
    });
  }
  
  void selectLastDate() async{
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },);

    setState(() {
      dateUpperBound = pickedDate;
      
    });
  }
  void filterDate(List<PostinganKasus> kasus, DateTime? dateTime1, dateTime2){
    if(dateTime1!= null){
      kasus.retainWhere((element) => element.tanggalPemostingan.isAfter(dateTime1) || element.tanggalPemostingan.isAtSameMomentAs(dateTime1));

    }
    if(dateTime2 != null){
      kasus.retainWhere((element) => element.tanggalPemostingan.isBefore(dateTime2) || element.tanggalPemostingan.isAtSameMomentAs(dateTime2));
    }

  }
  void filterTime(List<PostinganKasus> list, Waktu selected){
    if(selected == Waktu.Semua){
      return;
    }
    if(selected == Waktu.HariIni){
      list.retainWhere((element) => element.tanggalPemostingan.day == today.day && element.tanggalPemostingan.month ==
      today.month && element.tanggalPemostingan.year == today.year);
    }
    else if(selected == Waktu.BulanIni){
      list.retainWhere((element) => element.tanggalPemostingan.month == today.month && element.tanggalPemostingan.year
      == today.year);
    }
    else if(selected == Waktu.MingguIni){
      list.retainWhere((element) => (element.tanggalPemostingan.isAfter(startOfWeek) &&
      element.tanggalPemostingan.isBefore(today) || element.tanggalPemostingan.day == today.day ||
      element.tanggalPemostingan.day ==  startOfWeek.day));
    }
  }
  void sortBy(List<PostinganKasus> list, SortingKasus selected){
    if(selected != SortingKasus.Terdekat){
      list.sort(sortFunction[selected]);
    }else{
      if(currentLocation != null){
        list.sort((a,b){
          final koordinatA = a.lokasi.split(',');
          final koordinatB = b.lokasi.split(',');

          if(calculateDistance(
              double.parse(koordinatA[0].trim()), double.parse(koordinatA[1].trim()),
              currentLocation!.latitude!, currentLocation!.longitude!) <
              calculateDistance(
                  double.parse(koordinatB[0].trim()), double.parse(koordinatB[1].trim()),
                  currentLocation!.latitude!, currentLocation!.longitude!)){
            return -1;
          }
          else if(calculateDistance(
              double.parse(koordinatA[0].trim()), double.parse(koordinatA[1].trim()),
              currentLocation!.latitude!, currentLocation!.longitude!) >
              calculateDistance(
                  double.parse(koordinatB[0].trim()), double.parse(koordinatB[1].trim()),
                  currentLocation!.latitude!, currentLocation!.longitude!)){
            return 1;
          }
          return 0;
        });
      }
    }
  }
  void filterBy(List<PostinganKasus> list, TipeKasus tipe){
    if(tipe == TipeKasus.SemuaKategori){
      return;
    }
    list.retainWhere((element) => element.jenisKasus == tipe);
  }
  @override
  Widget build(BuildContext context) {
    final userList = ref.watch(userListProvider);
    final locationProviderData = ref.watch(locationProvider);
    // TODO: implement build
    return Scaffold(
      floatingActionButton:
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=> QuickReportPage()));
        },
        child: Icon(Icons.add, size: 24,),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: Color.fromRGBO(148, 26, 26, 1), // <-- Button color
        ),
      ),
      appBar:  AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      leading: Container(
        margin: EdgeInsets.only(left: 12),
        height: 24,
        width: 24,
        child: Image.asset('asset/logo-pantau.png',
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,),

      ),
      actions: [
        IconButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
          MapKejahatan(toMapKejahatan: (location){},listKasus: listKasus, location: PlaceLocation(latitude: currentLocation?.latitude ?? locationProviderData?.latitude?? -6.4025, longitude:  currentLocation?.longitude ?? locationProviderData?.longitude ?? 106.7942, address: ''),)));
        }, icon: const Icon(Icons.map, color: Color.fromRGBO(148, 26, 26, 1), size: 24,)),
        IconButton(onPressed: (){
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return HomepageSearch(cases: listKasus, users: userList, currentLocation:  currentLocation,);
          }));
        }, icon: const Icon(Icons.search_rounded, color: Colors.blue))
      ],
      title:
      Text(
        'Pantau',
        style: Theme.of(context).
        textTheme.headlineSmall!.
        copyWith(color:  const Color.fromRGBO(40,65,100,1)), ),
    ),
      body: StreamBuilder<Object>(
        stream: null,
        builder: (context, snapshotParent) {
          if(snapshotParent.connectionState == ConnectionState.waiting){
            return Center(child: CircularProgressIndicator(),);
          }
          return StreamBuilder(
            stream: FirebaseFirestore.instance.collection('posts').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot){

              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(color: Colors.blue,),
                );
              }
              listKasus = snapshot.data!.docs.map((doc) => PostinganKasus.fromMap(doc.data())).toList();
              final listKasusCopy = List<PostinganKasus>.from(listKasus).toList();
              listKasus.sort((a,b)=> (b.upvote.length - b.downvote.length).compareTo(a.upvote.length-a.downvote.length));
              final topKasus = listKasus.length < 5? listKasus.sublist(0,listKasus.length) : listKasus.sublist(0,5);
              sortBy(listKasusCopy, sortingSelected);
              filterBy(listKasusCopy, typeSelected);
              filterTime(listKasusCopy, timeSelected);
              filterDate(listKasusCopy, dateLowerBound, dateUpperBound);
              getCurrentLocation();

              return
                  SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 16 , horizontal:  16),
                            child: Text('Trending Kasus', style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                              color: Colors.black
                            ),),
                          ),
                        ),
                        CarouselWithIndicator(trendings: topKasus,toMapKejahatan:
                            (placeLocation){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                              MapKejahatan(toMapKejahatan: (location){},location: PlaceLocation(latitude:
                              currentLocation!.latitude!, longitude:  currentLocation!.longitude!, address: ''),
                                  markerPost: LatLng(placeLocation.latitude, placeLocation.longitude),listKasus: listKasus)));
                        },),
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
                                          child: DropdownButton<SortingKasus>(
                                            value: sortingSelected,
                                            iconEnabledColor: Colors.white60,
                                            hint: Text('Urutkan', style: Theme.of(context).textTheme.bodyMedium,),
                                            // Dropdown satu
                                            dropdownColor: Colors.blue, // Warna biru untuk dropdown menu
                                            items: [
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Postingan Terbaru',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.KirimanTerbaru,
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Postingan Terlama',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.KirimanTerlama,
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Terpopuler',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.Terpopuler,
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Kasus Terbaru',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.KasusTerbaru,
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Kasus Terlama',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.KasusTerlama,
                                              ),
                                              DropdownMenuItem(
                                                child: Text(
                                                  'Terdekat',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                                ),
                                                value: SortingKasus.Terdekat,
                                              ),
                                            ],
                                            onChanged: (value) {
                                              setState(() {
                                                if(value!= null)
                                                sortingSelected = value;
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
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<TipeKasus>(
                                      value: typeSelected,
                                      iconEnabledColor: Colors.white60,
                                      menuMaxHeight: 300,
                                      hint: Text('Kategori', style: Theme.of(context).textTheme.bodyMedium,),
                                      // Dropdown satu
                                      dropdownColor: Colors.blue, // Warna biru untuk dropdown menu
                                      items: [

                                        for(final kategori in TipeKasus.values)
                                          if(kategori == TipeKasus.SemuaKategori)
                                            DropdownMenuItem(child: Text(''
                                                'Semua Kategori',
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                            value: TipeKasus.SemuaKategori,)
                                          else if(kategori == TipeKasus.LaporanCepat) DropdownMenuItem(child: Text(''
                                              'Pelaporan Cepat',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                            value: TipeKasus.LaporanCepat,)
                                        else
                                          DropdownMenuItem(
                                          child: Text(
                                            kategori.name,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Warna teks putih
                                          ),
                                          value: kategori,
                                        ),
                                      ],
                                      onChanged: (value) {
                                        setState(() {
                                          if(value!= null) typeSelected = value;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ToggleSwitch(
                          initialLabelIndex: initialIndex,
                          minWidth: MediaQuery.of(context).size.width * 0.98,
                          inactiveBgColor: Colors.blueGrey,
                          onToggle: (value){

                            setState(() {
                              if(value!= null)
                                timeSelected = time[value];
                                initialIndex = value!;

                            });
                          },
                          curve: Curves.easeInOutExpo,
                          labels: ['Semua', 'Hari ini', 'Minggu ini', 'Bulan ini'],
                          radiusStyle:  true,

                        ),
                        Container(margin: EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(

                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      selectInitialDate();
                                      print(dateLowerBound);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.date_range),
                                        Text(dateLowerBound == null? 'Pilih tanggal awal' :
                                          DateFormat('dd-MM-yyyy').format(dateLowerBound!), textScaleFactor: 0.9,textAlign: TextAlign.center,),
                                      ],
                                    ),

                                  ),
                                ),

                                Icon(Icons.remove),

                                Flexible(
                                  child: ElevatedButton(

                                    onPressed: () {
                                      selectLastDate();
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        Icon(Icons.date_range),
                                        Text(dateUpperBound == null? 'Pilih tanggal akhir'
                                          : DateFormat('dd-MM-yyyy').format(dateUpperBound!), textScaleFactor: 0.9,textAlign: TextAlign.center,),
                                      ],
                                    ),
                                  ),
                                ),


                              ]),
                        ),


                        if(listKasusCopy.isNotEmpty)...listKasusCopy.map((e) => PostCard(toMapKejahatan:
                        (placeLocation){
                          Navigator.of(context).push(MaterialPageRoute(builder: (context)=>
                          MapKejahatan(toMapKejahatan: (location){},location: PlaceLocation(latitude: currentLocation?.latitude ?? locationProviderData?.latitude?? -6.4025, longitude:  currentLocation?.longitude ?? locationProviderData?.longitude ?? 106.7942, address: ''),
                              markerPost: LatLng(placeLocation.latitude, placeLocation.longitude),listKasus: listKasus)));
                        },kasus: e, asPost: true)).toList()
                        else Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Center(
                            child: Text('Tidak ada yang relevan dengan pilihan Anda', style: TextStyle(color: Colors.black),),
                          ),
                        )

                      ],
                    ),
                  );
            },
          );
        }
      )
    );
  }
}