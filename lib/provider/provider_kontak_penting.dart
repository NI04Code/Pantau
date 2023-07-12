import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kontak_penting.dart';
class KontakPentingStateNotifier extends StateNotifier<KontakPenting> {
  KontakPentingStateNotifier() : super(KontakPenting(
    noTelephone: {},
    mapMedsos: {},
    email: {},
  ));

  void resetState() {
    state = KontakPenting(
      noTelephone: {},
      mapMedsos: {},
      email: {},
    );
  }

  void setNoTelephone(Map<String, String> newNoTelephone) {
    state = state.copyWith(noTelephone: newNoTelephone);
  }

  void setMapMedsos(Map<String, String> newMapMedsos) {
    state = state.copyWith(mapMedsos: newMapMedsos);
  }

  void setEmail(Map<String, String> newEmail) {
    state = state.copyWith(email: newEmail);
  }
}
final kotakPentingProvider = StateNotifierProvider<KontakPentingStateNotifier, KontakPenting>((ref) => KontakPentingStateNotifier())
;
final container = ProviderContainer() ;
final kontakPentingContainer = container.read(kotakPentingProvider);


final emailProvider = StateProvider<Map<String,String>>((ref) => {});
final telephoneProvider = StateProvider<Map<String,String>>((ref) => {});

class MedsosStrings{
  Map<String, String> urlMaps;
  MedsosStrings(this.urlMaps);
}

final socialMediaProvider = StateProvider<MedsosStrings>((ref) => MedsosStrings(
    {
      'facebook':'',
      'instagram':'',
      'twitter':'',
      'linkedIn':''
    }
));