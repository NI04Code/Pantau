import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/widgets/bottom_navigation_bar.dart';

class BottomNavigationBarNotifier extends StateNotifier<int>{
  BottomNavigationBarNotifier() : super(0);
  void updateSelectedTab(int n){
    state = n;
  }
}
final bottomNavBarProvider = StateNotifierProvider<BottomNavigationBarNotifier, int>((ref) => BottomNavigationBarNotifier());