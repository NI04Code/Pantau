import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/provider/bottom_navigation_bar_provider.dart';
import 'package:pantau/screen/create_post_screen.dart';

class BottomNavbar extends ConsumerWidget{

  final List screens;
  final void Function(int) navigate;
  BottomNavbar({required this.screens, required this.navigate});


  final List<BottomNavigationBarItem> navItems = [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home_outlined),
      label: 'Beranda',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat_outlined),
      label: 'Pesan',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.create_outlined),
      label: 'Buat Postingan',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.favorite_outline_rounded),
      label: 'Diikuti',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person_outline),
      label: 'Profil',
    ),
  ];
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavBarProvider);
    // TODO: implement build
    return BottomNavigationBar(
      elevation: 0,
      items: navItems,
      currentIndex: selectedIndex,
      unselectedItemColor: Color.fromRGBO(40,65,100,1),
      selectedItemColor: Colors.blue,
      onTap: (index){
        ref.read(bottomNavBarProvider.notifier).updateSelectedTab(index);
        navigate(index);}
    );
  }
}