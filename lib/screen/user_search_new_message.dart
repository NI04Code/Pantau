import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/user.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/other_user_profile_page.dart';
import 'package:pantau/widgets/list_tile_user.dart';
import 'package:pantau/widgets/postcard_widget.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/screen/homepage.dart';

import 'map_kejahatan_screen.dart';

class UserMessageNewSearch extends ConsumerStatefulWidget {

  final List<User> users;
  const UserMessageNewSearch({super.key, required this.users, });
  @override
  _UserMessageNewSearchState createState() => _UserMessageNewSearchState();
}

class _UserMessageNewSearchState extends ConsumerState<UserMessageNewSearch> {
  TextEditingController? _searchController = TextEditingController();
  List<User>  usersFilter = [];
  bool search = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    _searchController!.dispose();
    super.dispose();
  }

  void _performSearch() {
    final currentUser = ref.watch(userProvider);
    setState(() {
      usersFilter = widget.users.where((thread) => thread.uid != currentUser.uid &&
          thread.username.toLowerCase().contains(_searchController!.text.trim().toLowerCase())).toList();
      search = true;
    });

  }

  Widget buildBeforeSearch(){
    return Center(child: Text('Mari Cari Pengguna', style: TextStyle(
        color: Colors.black
    ),));
  }

  Widget buildAfterSearch(){
    final locationDataSaver = ref.watch(locationProvider);
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
              margin:EdgeInsets.symmetric(horizontal:  20, vertical: 20),child: Align(alignment: Alignment.centerLeft,
              child: Text("Pengguna", style:  TextStyle(color: Colors.black, fontSize: 20),))),
          if ( usersFilter!.isEmpty )Container( constraints: BoxConstraints(maxHeight: 100),
              child: Center(child: Text('Tidak ada pengguna yang relevan dengan pencarian Anda',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w300),),))
          else for(final user in usersFilter!) Container( margin : EdgeInsets.only(bottom: 16), child: UserListTile(user: user),),


        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        //iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        title: Text('Cari Pengguna', style:  TextStyle(color: Colors.black),),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                        hintText: 'Cari Username',
                        border:  OutlineInputBorder()
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _performSearch,
                  icon: Icon(Icons.search_rounded, color: Colors.blue,),
                ),
              ],
            ),
          ),

          if(search == false) Expanded(child: buildBeforeSearch())
          else Flexible(child: buildAfterSearch())



        ],
      ),
    );
  }
}