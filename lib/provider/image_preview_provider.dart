

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class ImagePreviewNotifier extends StateNotifier<List<Uint8List>>{
  ImagePreviewNotifier() : super([]);
  void addImageFile(Uint8List file){
    state = [...state, file];
  }
  void endCheck(){
    print(state.length);
  }
}
final previewProvider  = StateNotifierProvider<ImagePreviewNotifier,List<Uint8List>>((ref) => ImagePreviewNotifier());