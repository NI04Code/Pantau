
import 'package:flutter/material.dart';
import 'package:pantau/models/like_dislike.dart';
import 'package:pantau/provider/like_dislike_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'kontak_penting.dart';
import 'kronologi.dart';

enum TipeKasus {
  SemuaKategori,
  LaporanCepat,
  Kekerasan,
  Pelecehan,
  Pencurian,
  Pembullyan,
  Pembegalan,
  Penipuan,
  Cybercrime,
  SARA,
  Diskriminasi,
  Pemerkosaan,
  Narkotika,
  Pembunuhan,
  Perusakan,
  Lainnya
}

class PostinganKasus{
  String uid; // dibuat oleh database
  String idPost;
  String judul;
  String deskripsi;
  TipeKasus jenisKasus;
  String lokasi;
  TimeOfDay waktuTerjadinyaKasus;
  TimeOfDay waktuPemostingan;
  DateTime tanggalTerjadinyaKasus;
  DateTime tanggalPemostingan; // dibuat oleh sistem
  List<String> gambarUrls;
  List<String> komentar;
  List<String> upvote;
  List<String> downvote;
  List<String> diikuti;
  String namaKorban;
  String keteranganKorban;
  String username;
  String thumbnail;
  KontakPenting kontakPenting;
  List<Kronologi> kronologis;
  List<String> rekamanSuara;
  List<String> video;


  
  PostinganKasus({required this.uid,
    required this.diikuti,
    required this.thumbnail,
    required this.idPost,
    required this.username,
    required this.waktuPemostingan,
    required this.judul,
    required this.waktuTerjadinyaKasus,
    required this.deskripsi,
    required this.jenisKasus,
    required this.lokasi,
    required this.tanggalTerjadinyaKasus,
    required this.tanggalPemostingan,
    required this.gambarUrls,
    required this.komentar,
    required this.upvote,
    required this.downvote,
    required this.namaKorban,
    required this.keteranganKorban,
    required this.kontakPenting,
    required this.kronologis,
    required this.rekamanSuara,
    required this.video
  });

  Map<String, dynamic> toMap() {
    DateTime now = DateTime.now();
    DateTime dateTimePosting = DateTime(
      tanggalPemostingan.year,
      tanggalPemostingan.month,
      tanggalPemostingan.day,
      waktuPemostingan.hour,
      waktuPemostingan.minute,
      tanggalPemostingan.second
    );
    DateTime dateTimeKasus = DateTime(
      tanggalTerjadinyaKasus.year,
      tanggalTerjadinyaKasus.month,
      tanggalTerjadinyaKasus.day,
      waktuTerjadinyaKasus.hour,
      waktuTerjadinyaKasus.minute,
    );
    return {
      'kronologis': kronologis.map((e) => e.toMap()).toList(),
      'kontakPenting': kontakPenting.toMap(),
      'uid': uid,
      'diikuti' : diikuti,
      'username': username,
      'idPost' : idPost,
      'judul': judul,
      'deskripsi': deskripsi,
      'jenisKasus': jenisKasus.name,
      'lokasi': lokasi,
      'tanggalTerjadinyaKasus': tanggalTerjadinyaKasus.toString(),
      'tanggalPemostingan': tanggalPemostingan.toString(),
      'gambarUrls': gambarUrls,
      'komentar': komentar,
      'upvote': upvote,
      'downvote' : downvote,
      'namaKorban' : namaKorban,
      'keteranganKorban' : keteranganKorban,
      'waktuTerjadinyaKasus' : dateTimeKasus.toString(),
      'waktuPemostingan' : dateTimePosting.toString(),
      'thumbnail' : thumbnail,
      'video' : video,
      'rekamanSuara':rekamanSuara
    };
  }
  factory PostinganKasus.fromMap(Map<String, dynamic> map) {
    final waktuPosting = TimeOfDay.fromDateTime(DateTime.parse(map['waktuPemostingan']));
    final waktuKasus = TimeOfDay.fromDateTime(DateTime.parse(map['waktuTerjadinyaKasus']));
    return PostinganKasus(
      diikuti: List<String>.from(map['diikuti']).toList(),
      video: List<String>.from(map['video']).toList(),
      rekamanSuara: List<String>.from(map['rekamanSuara']).toList(),
      kronologis: List<Map<String,dynamic>>.from(map['kronologis']).map((e) => Kronologi.fromMap(e)).toList(),
      kontakPenting: KontakPenting.fromMap(map['kontakPenting']),
      thumbnail: map['thumbnail'],
      username: map['username'],
      idPost: map['idPost'],
      waktuPemostingan: waktuPosting,
      waktuTerjadinyaKasus: waktuKasus,
      uid: map['uid'],
      judul: map['judul'],
      deskripsi: map['deskripsi'],
      jenisKasus: TipeKasus.values.firstWhere((element) => element.name == map['jenisKasus'] ),
      lokasi: map['lokasi'],
      tanggalTerjadinyaKasus: DateTime.parse(map['tanggalTerjadinyaKasus']),
      tanggalPemostingan: DateTime.parse(map['tanggalPemostingan']),
      gambarUrls: List<String>.from(map['gambarUrls']),
      komentar: List<String>.from(map['komentar']),
      upvote: List<String>.from(map['upvote']),
      downvote: List<String>.from(map['downvote']),
      namaKorban: map['namaKorban'],
      keteranganKorban: map['keteranganKorban']
    );
  }


}