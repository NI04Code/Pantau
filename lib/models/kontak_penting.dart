import 'package:flutter/material.dart';

class KontakPenting {
  final Map<String, String> noTelephone;
  final Map<String, String> mapMedsos;
  final Map<String, String> email;

  KontakPenting({
    required this.noTelephone,
    required this.mapMedsos,
    required this.email,
  });

  KontakPenting copyWith({
    Map<String, String>? noTelephone,
    Map<String, String>? mapMedsos,
    Map<String, String>? email,
  }) {
    return KontakPenting(
      noTelephone: noTelephone ?? this.noTelephone,
      mapMedsos: mapMedsos ?? this.mapMedsos,
      email: email ?? this.email,
    );
  }

  factory KontakPenting.fromMap(Map<String, dynamic> map) {
    return KontakPenting(
      noTelephone: Map<String, String>.from(map['noTelephones']),
      mapMedsos: Map<String, String>.from(map['mapMedsos']),
      email: Map<String, String>.from(map['emails']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'noTelephones': noTelephone,
      'mapMedsos': mapMedsos,
      'emails': email,
    };
  }
}