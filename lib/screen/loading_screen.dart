import 'package:flutter/material.dart';
import 'dart:async';

import 'package:pantau/screen/auth_screen.dart';

class LoadingScreen extends StatefulWidget{
  const LoadingScreen({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoadingScreenState();
  }
}
class _LoadingScreenState extends State<LoadingScreen>{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 2), () {
      // Setelah 2 detik, berpindah ke halaman berikutnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 72,bottom: 96),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset('asset/logo-pantau.png', width: 140, height: 140,),
              Text('Pantau',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black, fontSize: 24), textAlign: TextAlign.center,),
              const SizedBox(height: 8,),
              Text('Bersama Mewujudkan Keadilan',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 20), textAlign: TextAlign.center,),
              const Spacer(),
              const CircularProgressIndicator(color: Color.fromRGBO(37, 124, 225, 1),)
            ],
          ),
        ),
      ),
    );
  }
}