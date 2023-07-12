import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

pickImage(ImageSource imageSource) async {
  XFile? file = await ImagePicker().pickImage(source: imageSource);
  if(file!= null){
    return await file.readAsBytes();
  }
}