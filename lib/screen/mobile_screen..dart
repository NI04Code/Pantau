
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/user.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/create_post_screen.dart';
import 'package:pantau/screen/diikuti_screen.dart';
import 'package:pantau/screen/homepage.dart';
import 'package:pantau/screen/posting_kasus_screen.dart';
import 'package:pantau/screen/profile_page.dart';
import 'package:pantau/widgets/bottom_navigation_bar.dart';
import 'package:pantau/main.dart';
import 'package:pantau/provider/bottom_navigation_bar_provider.dart';
import 'package:pantau/resources/auth.dart';
import 'package:pantau/screen/pesan_screen.dart';

class MobileScreen extends ConsumerStatefulWidget{
  ConsumerState<MobileScreen> createState() {
    // TODO: implement createState
    return _HomepageState();
  }
}
class _HomepageState extends ConsumerState<MobileScreen>{
  
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //getUserInformation();
    getUsername();
    
  }
  void getUsername()async{
    DocumentSnapshot doc = await Auth.instance.firebase.collection('users').
    doc(Auth.instance.firebaseAuth.currentUser!.uid).get();
    ref.read(userProvider.notifier).updateUser(User.buildUser(doc));
    print(ref.read(userProvider.notifier).state.convertJSON());

  }
  void getUserInformation()async{
    ref.read(userProvider.notifier).updateUid(Auth.instance.firebaseAuth.currentUser!.uid);
    DocumentSnapshot snapshot = await Auth.instance.firebase.collection('users').doc(ref.watch(userProvider).uid).get();
    ref.read(userProvider.notifier).updateUser(User.buildUser(snapshot));

  }
  final pageController = PageController();
  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final selectedTab = ref.watch(bottomNavBarProvider);
    print(user == null);
    final screens =  [
      HomeScreen(),
      PesanScreen(),
      PostingKasusScreen(),
      DiikutiScreen(),
      ProfilePage(user: user)
    ];
    // TODO: implement build
    return Scaffold(

      body: PageView(
        physics: ClampingScrollPhysics(),
        controller: pageController ,
        onPageChanged: (index){
          pageController.jumpToPage(index);
          ref.read(bottomNavBarProvider.notifier).updateSelectedTab(index);
        },
        children: screens,
      ),
      bottomNavigationBar: BottomNavbar(screens: screens, navigate: (int index){
        try {
          pageController.jumpToPage(index);
        } catch(e){}
        //ref.read(bottomNavBarProvider.notifier).updateSelectedTab(index);

      }),
    );
  }
}