import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kronologi.dart';
import 'package:pantau/screen/kronologi_screen.dart';

final kronologisProvider = StateProvider<KronologiScreen>((ref) => KronologiScreen());
final kronologisListProvider  = StateProvider<List<Kronologi>>((ref) => []);