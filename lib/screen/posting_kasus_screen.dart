import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/models/kontak_penting.dart';
import 'package:pantau/screen/create_post_screen.dart';
import 'package:pantau/screen/kontak_penting_input_screen.dart';
import 'package:pantau/screen/kronologi_screen.dart';
import 'package:pantau/provider/kronologis_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/kronologi_screen.dart';
import 'package:pantau/screen/mobile_screen..dart';
import 'package:pantau/widgets/date_and_time_picker.dart';
import 'package:pantau/widgets/datetime_picker.dart';
import 'package:pantau/widgets/kategori.dart';
import 'package:pantau/widgets/kategori.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/widgets/image_picker.dart';
import 'package:pantau/provider/image_preview_provider.dart';
import 'package:pantau/widgets/location-widget.dart';
import 'package:uuid/uuid.dart';
import 'package:pantau/resources/auth.dart';
import 'package:pantau/provider/provider_kontak_penting.dart';


final dataKasusScreen = StateProvider<PostScreen>((ref) => PostScreen());

class PostingKasusScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<PostingKasusScreen> createState() => _TabBarScreenState();
}

class _TabBarScreenState extends ConsumerState<PostingKasusScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool isPost = false;

  Future<void> buatPostingan() async{

    final kronologis = ref.watch(kronologisListProvider);
    final telephones = ref.watch(telephoneProvider);
    final emails = ref.watch(emailProvider);
    final facebook = ref.watch(facebookStringProvider);
    final twitter = ref.watch(twitterStringProvider);
    final instagram = ref.watch(instagramStringProvider);
    final linkedIn = ref.watch(linkedInStringProvider);

    final title = ref.watch(titleRememberProvider);
    final description = ref.watch(deskripsiRememberProvider);
    final victimName = ref.watch(namaKorbanRememberProvider);
    final victimDetails = ref.watch(keteranganKorbanRememberProvider);
    final location = ref.watch(locationRemember);
    final tanggal = ref.watch(dateTimeSelectedRemember);
    final jam = ref.watch(timeOfDaySelectedRemember);
    final thumbnail = ref.watch(thumbnailRemember);
    final bukti = ref.watch(previewProvider);
    final postId = const Uuid().v1();
    final user = ref.watch(userProvider);
    final categoryIndex = ref.watch(selectedCategoryProvider);
    final key = ref.watch(globalKeyRemember);


    if(title == '' && description == ''){
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Data belum lengkap')));
      return;
    }
    setState(() {
      isPost = true;
    });

    KontakPenting kontak = KontakPenting(noTelephone: telephones, mapMedsos:
    {
      'facebook' : facebook,
      'twitter' : twitter,
      'instagram':instagram,
      'linkedIn':linkedIn
    }, email: emails);

    List<String> imagesUrl = [];
    String thumbnailUrl = '';
    try {
      for(final file in bukti) {
        imagesUrl.add(await Auth.instance.uploadImageToStorage(
            childName: 'posts', file: file, isPost: true));}

      if(thumbnail != null){
        thumbnailUrl = await Auth.instance.uploadImageToStorage(
            childName: 'posts/thumbnail', file: thumbnail!, isPost: true);
      }
    } on Exception catch (e) {
      // TODO
      print(e);
    }
    PostinganKasus kasus = PostinganKasus(
        diikuti: [],
        uid: user.uid,
        video: [],
        rekamanSuara: [],
        thumbnail: thumbnailUrl,
        idPost: postId,
        username: user.username,
        waktuPemostingan: TimeOfDay.now() ,
        judul: title,
        waktuTerjadinyaKasus: jam,
        deskripsi: description,
        jenisKasus: TipeKasus.values[categoryIndex],
        lokasi: '${location!.latitude},${location!.longitude}',
        tanggalTerjadinyaKasus: tanggal,
        tanggalPemostingan: DateTime.now(),
        gambarUrls: imagesUrl,
        komentar: [],
        upvote: [],
        downvote: [],
        namaKorban: victimName,
        keteranganKorban: victimDetails,
        kontakPenting: kontak,
        kronologis: kronologis);

    try {
      final res = await Auth.instance.firebase.collection('posts').doc(postId).set(
          kasus.toMap());
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil memposting kasus')));

      ref.refresh(globalKeyRemember);
      ref.refresh(helperSendDataProvider);
      ref.refresh(dataKasusScreen);

      ref.refresh(titleRememberProvider);
      ref.refresh(deskripsiRememberProvider);
      ref.refresh(namaKorbanRememberProvider);
      ref.refresh(keteranganKorbanRememberProvider);
      ref.refresh(locationRemember);
      ref.refresh(dateTimeSelectedRemember);
      ref.refresh(timeOfDaySelectedRemember);
      ref.refresh(thumbnailRemember);

      for(final provider in providerSocialMediaMap.values){
        ref.refresh(provider);
      }

      ref.refresh(socialMediaProvider);
      ref.refresh(kronologisListProvider);
      ref.refresh(selectedCategoryProvider);
      ref.refresh(categoryExtendedProvider);
      ref.refresh(previewProvider);
      ref.refresh(isSelectedProvider);
      ref.refresh(emailProvider);
      ref.refresh(telephoneProvider);
    } on Exception catch (e) {
      print(e);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memposting kasus')));
    }finally{
      setState(() {
        isPost = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  @override
  void deactivate() {
    // TODO: implement deactivate
    print('here');
    ref.refresh(globalKeyRemember);
    ref.refresh(helperSendDataProvider);
    ref.refresh(dataKasusScreen);

    ref.refresh(titleRememberProvider);
    ref.refresh(deskripsiRememberProvider);
    ref.refresh(namaKorbanRememberProvider);
    ref.refresh(keteranganKorbanRememberProvider);
    ref.refresh(locationRemember);
    ref.refresh(dateTimeSelectedRemember);
    ref.refresh(timeOfDaySelectedRemember);
    ref.refresh(thumbnailRemember);
    for(final provider in providerSocialMediaMap.values){
      ref.refresh(provider);
    }

    ref.refresh(socialMediaProvider);
    ref.refresh(kronologisListProvider);
    ref.refresh(selectedCategoryProvider);
    ref.refresh(categoryExtendedProvider);
    ref.refresh(previewProvider);
    ref.refresh(isSelectedProvider);
    ref.refresh(emailProvider);
    ref.refresh(telephoneProvider);
    super.deactivate();
  }

  @override
  void dispose() {
    print('object');
    try{

    }
    catch(e){
      print('catch');
    }
    _tabController.dispose();
    print('hereeeeee');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final datakasus = ref.watch(dataKasusScreen);


    return Scaffold(

      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              buatPostingan();
            },
            icon: !isPost? Icon(Icons.send, color: Colors.blue,) : CircularProgressIndicator()
          ),
        ],
        elevation: 0,
        title: Text('Posting Kasus', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),),
        backgroundColor: Colors.white,
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          indicatorColor: Colors.blue,
          labelColor: Colors.black,
          tabs: [
            Tab(
              text: 'Data',
            ),
            Tab(
              text: 'Kronologi',
            ),
            Tab(
              text: 'Kontak Tambahan',
            ),
          ],
        ),
      ),
      body: TabBarView(

        controller: _tabController,

        children: [
          ref.watch(dataKasusScreen),
          KronologiScreen(),
          KontakPentingScreen(),
        ],
      ),
    );
  }
}