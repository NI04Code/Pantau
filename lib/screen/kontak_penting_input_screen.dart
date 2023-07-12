

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kontak_penting.dart';
import 'package:pantau/provider/provider_kontak_penting.dart';

final facebookStringProvider = StateProvider<String>((ref) => '');
final instagramStringProvider = StateProvider<String>((ref) => '');
final twitterStringProvider = StateProvider<String>((ref) => '');
final linkedInStringProvider = StateProvider<String>((ref) => '');

final providerSocialMediaMap = {
  'facebook':facebookStringProvider,
  'instagram':instagramStringProvider,
  'twitter':twitterStringProvider,
  'linkedIn':linkedInStringProvider
};

class KontakPentingScreen extends ConsumerStatefulWidget {

  const KontakPentingScreen({super.key, });

  @override
  _KontakPentingScreenState createState() => _KontakPentingScreenState();
}

class _KontakPentingScreenState extends ConsumerState<KontakPentingScreen> {



  TextEditingController _namaEmailController = TextEditingController();
  TextEditingController _alamatEmailController = TextEditingController();
  TextEditingController _namaTeleponController = TextEditingController();
  TextEditingController _nomorTeleponController = TextEditingController();
  String facebookString = '';
  String twitterString = '';
  String instagramString = '';
  String linkedInString = '';





  @override
  void deactivate() {

    // TODO: implement deactivate
    super.deactivate();
  }

  @override
  void dispose() {

    _namaEmailController.clear();
    _alamatEmailController.clear();
    _namaTeleponController.clear();
    _nomorTeleponController.clear();

    _namaEmailController.dispose();
    _alamatEmailController.dispose();
    _namaTeleponController.dispose();
    _nomorTeleponController.dispose();

    super.dispose();
  }

  Widget addMediaSocialInput(String input, String url, String label){
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListTile(
          leading: Image.network(
            url,
            fit: BoxFit.cover,),
          title: TextFormField(
            initialValue: input,
            onChanged: (value){
              input = value;
              ref.read(providerSocialMediaMap[label]!.notifier).state = value;
            },
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              labelText: 'Link '+label+' Anda',
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(width: 2, color: Colors.blue)
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(width: 2, color: Colors.blue)
              ),
            ),
          )
      ),
    );
  }

  void tambahEmail(String nama, String alamat) {

    _namaEmailController.clear();
    _alamatEmailController.clear();
    final emails = ref.watch(emailProvider);
    emails[nama] = alamat;
    ref.read(emailProvider.notifier).state = {...emails};
  }

  void tambahNomorTelepon(String nama, String nomor) {

    _namaTeleponController.clear();
    _nomorTeleponController.clear();
    final telephones = ref.watch(telephoneProvider);
    telephones[nama] = nomor;
    ref.read(telephoneProvider.notifier).state = {...telephones};

  }



  void showDialogTambahEmail(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Email'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaEmailController,
                decoration: InputDecoration(
                  labelText: 'Nama Pemilik Email',
                ),
              ),
              TextField(
                controller: _alamatEmailController,
                decoration: InputDecoration(
                  labelText: 'Alamat Email',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_namaEmailController.text.isNotEmpty &&
                    _alamatEmailController.text.isNotEmpty) {
                  tambahEmail(
                      _namaEmailController.text, _alamatEmailController.text);
                }
                Navigator.pop(context);
              },
              child: Text('Tambah',),
            ),
          ],
        );
      },
    );
  }

  void showDialogTambahNomorTelepon(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Tambah Nomor Telepon'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nama Kontak',
                ),
              ),
              TextField(
                controller: _nomorTeleponController,
                decoration: InputDecoration(
                  labelText: 'Nomor Telepon',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (_namaTeleponController.text.isNotEmpty &&
                    _nomorTeleponController.text.isNotEmpty) {
                  tambahNomorTelepon(
                      _namaTeleponController.text, _nomorTeleponController.text);
                }
                Navigator.pop(context);
              },
              child: Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emails = ref.watch(emailProvider);
    final telephones = ref.watch(telephoneProvider);
    facebookString = ref.watch(facebookStringProvider);
    instagramString = ref.watch(instagramStringProvider);
    linkedInString = ref.watch(linkedInStringProvider);
    twitterString = ref.watch(twitterStringProvider);


    return Scaffold(
      body: ListView(
        children: [
         Padding(
           padding: const EdgeInsets.all(8.0),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.center,
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Row(
                 children: [
                   Icon(Icons.email, color:  Colors.blue,),
                   SizedBox(width: 16,),
                   Text('Email', style: Theme.of(context).textTheme.bodyLarge!.
                   copyWith(color: Colors.black, fontSize: 20),),
                 ],
               ),
               IconButton(onPressed: (){
                 showDialogTambahEmail(context);

               }, icon: Icon(Icons.add, color: Colors.blue,))
             ],

           ),
         ),

          if(emails.isEmpty )Center(child: Text('Belum ada data', style:
            TextStyle(color: Colors.black),),) else for(final entry in emails.entries) ListTile(
            title: Text(entry.key, style: TextStyle(color: Colors.black),),
            subtitle: Text(entry.value, style: TextStyle(color: Colors.black),),
          ),


          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.phone, color:  Colors.blue,),
                    SizedBox(width: 16,),
                    Text('Nomor Telepon', style: Theme.of(context).textTheme.bodyLarge!.
                    copyWith(color: Colors.black, fontSize: 20),),
                  ],
                ),
                IconButton(onPressed: (){
                  showDialogTambahNomorTelepon(context);
                }, icon: Icon(Icons.add, color: Colors.blue,))
              ],

            ),
          ),
          if(telephones.isEmpty) Center(child: Text('Belum ada data', style:
          TextStyle(color: Colors.black),),) else for(final entry in telephones.entries) ListTile(
            title: Text(entry.key, style: TextStyle(color: Colors.black),),
            subtitle: Text(entry.value, style: TextStyle(color: Colors.black),),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  //mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.web_outlined, color:  Colors.blue,),
                    SizedBox(width: 16,),
                    Text('Media Sosial', style: Theme.of(context).textTheme.bodyLarge!.
                    copyWith(color: Colors.black, fontSize: 20),),
                  ],
                ),

              ],

            ),
          ),

           addMediaSocialInput(facebookString!,
               'https://img.icons8.com/?size=512&id=13912&format=png', 'facebook'),
          addMediaSocialInput(instagramString!,
              'https://img.icons8.com/?size=512&id=Xy10Jcu1L2Su&format=png', 'instagram'),
          addMediaSocialInput(twitterString!, 'https://img.icons8.com/?size=512&id=13963&format=png', 'twitter'),
          addMediaSocialInput(twitterString!, 'https://img.icons8.com/?size=512&id=xuvGCOXi8Wyg&format=png', 'linkedIn'),


        ],
      ),

    );
  }
}