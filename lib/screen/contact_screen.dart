import 'package:flutter/material.dart';
import 'package:pantau/models/kasus.dart';
import 'package:url_launcher/url_launcher.dart';

String addUrlScheme(String url) {
  if (!url.startsWith('http://') && !url.startsWith('https://')) {
    return 'http://' + url;
  }
  return url;
}

class KontakScreen extends StatelessWidget {
  final PostinganKasus kasus;
  const KontakScreen({super.key,required this.kasus});
  void _launchURL(String urlString) async {
    final url = Uri.parse(addUrlScheme(urlString));
    if (await canLaunchUrl(url)) {
      await launchUrl(url,
      mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
  void _launchEmail(String urlString) async {
    final url =  Uri(
      scheme: 'mailto',
      path: urlString,
      query: encodeQueryParameters(<String, String>{
        'subject': 'halo',
        'body':'halo'
      }),
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url,
          mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
  void _launchTelephone(String tel) async{
    final url = Uri.parse('tel:'+tel);
      await launchUrl(url);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
      kasus.kontakPenting.email.values.every((element) => element.isEmpty) &&
          kasus.kontakPenting.noTelephone.values.every((element) => element.isEmpty)&&
          kasus.kontakPenting.mapMedsos.values.every((element) => element.isEmpty) ?
          Center(child: Text('Pengguna tidak mencantumkan kontak penting',
          style: const  TextStyle(color: Colors.black),),) : ListView(
          padding: EdgeInsets.all(16),
          children: [

          for(final entry in kasus.kontakPenting.noTelephone.entries)
            _buildPhoneCard(entry.value, entry.key),
          for(final entry in kasus.kontakPenting.email.entries)
            _buildEmailCard(entry.value, entry.key),
          Wrap(
            alignment: WrapAlignment.center,
            children: [
              if(kasus.kontakPenting.mapMedsos['facebook']!.isNotEmpty)
                _buildSocialMediaCard(kasus.kontakPenting.mapMedsos['facebook']!, 'https://img.icons8.com/?size=512&id=13912&format=png'),
              if(kasus.kontakPenting.mapMedsos['twitter']!.isNotEmpty)
                _buildSocialMediaCard(kasus.kontakPenting.mapMedsos['twitter']!, 'https://img.icons8.com/?size=512&id=5dzPqHelxBq4&format=png'),
              if(kasus.kontakPenting.mapMedsos['instagram']!.isNotEmpty)

                _buildSocialMediaCard(kasus.kontakPenting.mapMedsos['instagram']!, 'https://img.icons8.com/?size=512&id=Xy10Jcu1L2Su&format=png'),
              if(kasus.kontakPenting.mapMedsos['linkedIn']!.isNotEmpty)
                _buildSocialMediaCard(kasus.kontakPenting.mapMedsos['linkedIn']!, 'https://img.icons8.com/?size=512&id=xuvGCOXi8Wyg&format=png'),
            ],
          )
          
        ],
      ),
    );
  }

  Widget _buildPhoneCard(String phoneNumber, String callerName) {
    return Card(
      child: ListTile(

        title: Text(
          '$callerName',
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          phoneNumber,
          style: TextStyle(color: Colors.black),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.call),
              color: Colors.blue,
              onPressed: () {
                _launchTelephone(phoneNumber);
              },
            ),
            IconButton(
              icon: Icon(Icons.message),
              color: Colors.blue,
              onPressed: () {
                _launchURL('https://wa.me/62${phoneNumber}');
              },
            ),
          ],
        ),
        onTap: () {
          // Aksi yang ingin dilakukan saat card di tekan
          // Misalnya, menampilkan detail kontak telepon
        },
      ),
    );
  }

  Widget _buildEmailCard(String email, String senderName) {
    return Card(
      child: ListTile(

        title: Text(
          '$senderName',
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          email,
          style: TextStyle(color: Colors.black),
        ),
        trailing: IconButton(
          icon: Icon(Icons.mail),
          color: Colors.blue,
          onPressed: () {
            _launchEmail(email);
            // Aksi yang ingin dilakukan saat tombol email di tekan
            // Misalnya, membuka aplikasi email dengan alamat email yang sudah diisi
          },
        ),
      ),
    );
  }

  Widget _buildSocialMediaCard(String socialMedia, String imageUrl) {
    return InkWell(
      onTap: () {
        _launchURL(socialMedia);
      },
      child:  Padding(
        padding: EdgeInsets.all(16),
        child: CircleAvatar(
          radius: 40,
          backgroundImage: NetworkImage(imageUrl),
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
    );
  }
}