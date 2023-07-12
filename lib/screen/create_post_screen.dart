
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pantau/models/kasus.dart';
import 'package:pantau/models/kontak_penting.dart';
import 'package:pantau/models/place_location.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:pantau/screen/kronologi_screen.dart';
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


final helperSendDataProvider = StateProvider<Future<PostinganKasus?>Function()>((ref) {
  return () async{
    return null;
  };
});

final titleRememberProvider = StateProvider<String>((ref){
  return '';
});

final deskripsiRememberProvider = StateProvider<String>((ref){
  return '';
});
final namaKorbanRememberProvider = StateProvider<String>((ref){
  return '';
});

final keteranganKorbanRememberProvider = StateProvider<String>((ref){
  return '';
});
final locationRemember = StateProvider<PlaceLocation?>((ref) => null);

final dateTimeSelectedRemember = StateProvider<DateTime>((ref) => DateTime.now());

final timeOfDaySelectedRemember = StateProvider<TimeOfDay>((ref) => TimeOfDay.now());

final thumbnailRemember = StateProvider<Uint8List?>((ref) => null);
final globalKeyRemember = StateProvider<GlobalKey<FormState>>((ref) => GlobalKey());


const uuid = const Uuid();
final resProviderDataForm = StateProvider<String>((ref) => 'no content');
//final imagePostProvider = StateProvider<List<Uint8List>>((ref) => []);




class PostScreen extends ConsumerStatefulWidget{

  const PostScreen({super.key});
  @override
  ConsumerState<PostScreen> createState() {
    // TODO: implement createState
    return _PostScreenState();
  }
}
class _PostScreenState extends ConsumerState<PostScreen>{
  GlobalKey<FormState>? _formKey;
  String? title;
  String? description;
  String? victimName;
  String? victimDetail;
  PlaceLocation? userLocation;//
  TipeKasus? tipeKasus;//
  DateTime? dateTimeSelected;//
  TimeOfDay? timeOfDaySelected;//
  Uint8List? thumbnail; //
  bool isPost = false;

  @override
  void initState() {

    super.initState();

  }
  _selectThumbnail(BuildContext context) async{
    return showDialog
      (context: context, builder: (context){
      return SimpleDialog(
        title:  Text('Dapatkan Bukti', style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            color: const Color.fromRGBO(40,65,100,1) ),),
        children: [
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Text('Ambil foto atau video', style : Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: const Color.fromRGBO(40,65,100,1) ),),
            onPressed: () async{
              Navigator.of(context).pop();
              Uint8List file = await pickImage(ImageSource.camera);
              if(file!=null){
                setState(() {
                  thumbnail = file;
                  ref.read(thumbnailRemember.notifier).state = file;
                });

              }
            },
          ),
          SimpleDialogOption(
            padding: EdgeInsets.all(20),
            child: Text('Dapatkan dari galeri', style:Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: const Color.fromRGBO(40,65,100,1) )),
            onPressed: () async{
              Navigator.of(context).pop();
              Uint8List file = await pickImage(ImageSource.gallery);
              if(file != null){
                setState(() {
                  thumbnail = file;
                  ref.read(thumbnailRemember.notifier).state = file;
                });
              }
            },
          )
        ],
      );
    });
  }


  _selectImage(BuildContext context) async{
    print('anjir susaah');
    return showDialog
      (context: context, builder: (context){
        return SimpleDialog(
          title:  Text('Dapatkan Bukti', style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              color: const Color.fromRGBO(40,65,100,1) ),),
          children: [
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: Text('Ambil foto atau video', style : Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: const Color.fromRGBO(40,65,100,1) ),),
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.camera);
                if(file!=null){
                  ref.read(previewProvider.notifier).addImageFile(file);
                }
              },
            ),
            SimpleDialogOption(
              padding: EdgeInsets.all(20),
              child: Text('Dapatkan dari galeri', style:Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: const Color.fromRGBO(40,65,100,1) )),
              onPressed: () async{
                Navigator.of(context).pop();
                Uint8List file = await pickImage(ImageSource.gallery);
                if(file != null){
                  ref.read(previewProvider.notifier).addImageFile(file);
                }
              },
            )
          ],
        );
    });
  }

  @override
  void deactivate() {
    // TODO: implement deactivate

    //ref.refresh(imagePreviewProvider);
    print('here');
    super.deactivate();
  }
  void dispose(){
    super.dispose();
  }

  Future<PostinganKasus?> _saveForm() async{
    final _formKey = ref.watch(globalKeyRemember);
    PostinganKasus? kasusBaru;
    final user = ref.watch(userProvider);
    print(user.convertJSON());
    print(context.toString());
  //  print(_titleController!.text);
    List<String> imagesUrl = [];
    String res = 'Terdapat kesalahan';
    final isValid = _formKey!.currentState!.validate();
    final categorySelected = ref.watch(isSelectedProvider);
    final selectedCategoryIndex = ref.watch(selectedCategoryProvider);
    final selectedImagesToPost = ref.watch(previewProvider);
    if(isValid && categorySelected && selectedCategoryIndex != -1 && userLocation != null){
      setState(() {
        isPost = true;
      });
      final currentTimeOfDay = TimeOfDay.now();
      final currentDateTime = DateTime.now();
      PlaceLocation selectedLocation = userLocation!;

      try{
        for(final file in selectedImagesToPost) {
          imagesUrl.add(await Auth.instance.uploadImageToStorage(
              childName: 'posts', file: file, isPost: true));}
        String? thumbnailUrl;
        if(thumbnail != null){
               thumbnailUrl = await Auth.instance.uploadImageToStorage(
              childName: 'posts/thumbnail', file: thumbnail!, isPost: true);
        }
          final postId = uuid.v1();
          kasusBaru = PostinganKasus
            ( uid: user.uid,
              diikuti: [],
              rekamanSuara: [],
              video: [],
              thumbnail: thumbnailUrl ?? '',
              idPost: postId,
              username: user.username,
              waktuPemostingan: currentTimeOfDay,
              judul: title!,
              waktuTerjadinyaKasus: timeOfDaySelected ?? currentTimeOfDay,
              deskripsi: description!,
              jenisKasus: TipeKasus.values[selectedCategoryIndex],
              lokasi: '${selectedLocation.latitude},${selectedLocation.longitude}',
              tanggalTerjadinyaKasus: dateTimeSelected ?? currentDateTime ,
              tanggalPemostingan: DateTime.now(),
              gambarUrls: imagesUrl,
              komentar: [],
              upvote: [],
              downvote: [],
              namaKorban: victimName!,
              keteranganKorban: victimDetail!,
          kronologis: [],
          kontakPenting: KontakPenting(noTelephone: {}, email: {}, mapMedsos: {},
          ));
          print(kasusBaru.toMap());
          await Auth.instance.firebase.collection('posts').doc(postId).set(
              kasusBaru.toMap());
          res = 'success';
          setState(() {
            isPost = false;
          });
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Berhasil memposting kasus')));
      }catch(error){
        res = error.toString();
        print(res);
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal posting')));
      }
      ref.read(resProviderDataForm.notifier).state = res;
    }
    return kasusBaru;

  }
  @override
  Widget build(BuildContext context) {
    _formKey = ref.watch(globalKeyRemember);
    title = ref.watch(titleRememberProvider);
    description = ref.watch(deskripsiRememberProvider);
    victimName = ref.watch(namaKorbanRememberProvider);
    victimDetail = ref.watch(keteranganKorbanRememberProvider);
    userLocation = ref.watch(locationRemember);
    final isExtendedCategory = ref.watch(categoryExtendedProvider);
    final horizontalViewList = ref.watch(previewProvider);
    thumbnail = ref.watch(thumbnailRemember);
    dateTimeSelected = ref.watch(dateTimeSelectedRemember);
    timeOfDaySelected = ref.watch(timeOfDaySelectedRemember);

    // TODO: implement build
    return Scaffold(

      body: SingleChildScrollView(
        child: MediaQuery.of(context).size.width  < 840 ?Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // ------------------------------ JUDUL DAN TEXTFORMFIELD --------------------------------
                Text(
                  'Judul',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color:  const Color.fromRGBO(40,65,100,1)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:16),
                  constraints: BoxConstraints(maxWidth: 550),
                  child: TextFormField(

                    initialValue: title,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.name,
                    validator: (value){
                      if(value == null || value.trim().isEmpty){
                        return 'Anda belum memasukkan judul kasus';
                      }
                    },
                    onChanged: (value){
                      if(value != null){
                        ref.read(titleRememberProvider.notifier).state = value;
                        title = value;
                      }
                    },
                    onSaved: (value){
                      title = value;
                    },
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color.fromRGBO(40,65,100,1) ),
                    decoration: InputDecoration(
                        hintText: 'Tuliskan judul kasus...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Color.fromRGBO(67,101,109,1)
                        ),
                        filled:  true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                        )
                    ),

                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Kategori',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:  const Color.fromRGBO(40,65,100,1)
                      ),
                    ),
                    IconButton(onPressed: (){
                      ref.read(categoryExtendedProvider.notifier).state = !ref.read(categoryExtendedProvider.notifier).state;
                    }, icon: Icon(!isExtendedCategory? Icons.add : Icons.minimize, color:
                    const Color.fromRGBO(40,65,100,1),))
                  ],
                ),
                SizedBox(height: 10,),
                CategorySelection(),
                SizedBox(height: 10,),
                // --------------------------------  DESKRIPSI DAN TEXTFORMFIELD
                Text(
                  'Deskripsi',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color:  const Color.fromRGBO(40,65,100,1)
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:16),
                  child: TextFormField(
                    initialValue: description,
                    validator: (value){
                      if(value == null || value.trim().isEmpty){
                        return 'Tolong tuliskan deskripsi kasus yang ingin Anda unggah';
                      }
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLines: 7,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color.fromRGBO(40,65,100,1) ),
                    decoration: InputDecoration(
                        hintText: 'Tuliskan deskripsi kasus...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color.fromRGBO(67,101,109,1)
                        ),
                        filled:  true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                        )
                    ),
                    onChanged: (value) {
                      description = value;
                      ref.read(deskripsiRememberProvider.notifier).state = value;
                    },
                    onSaved: (value){
                      description = value;
                    },
                  ),
                ),
                SizedBox(height: 10,),



                // ------------------------------ BUKTI ---------------------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tambahkan Bukti',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:  const Color.fromRGBO(40,65,100,1)
                      ),
                    ),
                    IconButton(onPressed: (){
                      _selectImage(context);
                    }, icon: const Icon(Icons.add, color:
                     Color.fromRGBO(40,65,100,1),)),
                  ],
                ),
                //ImagePreview()
                horizontalViewList.isEmpty? Container(
                  margin: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Mohon upload bukti kasus jika tersedia',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.black
                      ),
                    ),
                  ),
                ):SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: horizontalViewList.length,
                    itemBuilder: (ctx, idx) {

                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onLongPress: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: Text(
                                  'Mohon upload bukti kasus jika tersedia',
                                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                      color: Colors.black
                                  ),
                                ),
                                  actions: [
                              TextButton(
                              child: Text('Batal'),
                              onPressed: () {
                              Navigator.of(context).pop();
                              },
                              ),
                              TextButton(
                              child: Text('Hapus'),
                              onPressed: () {
                              setState(() {
                              horizontalViewList.removeAt(idx);
                              });
                              Navigator.of(context).pop();
                              },
                              ),]
                              );
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(

                                color: Colors.blue,
                                width: 2
                              )
                            ),
                            child: Image.memory(
                                horizontalViewList[idx], height: 150, width: 150,
                                fit:  BoxFit.cover,),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 5,),

            // --------------------------------------- THUMBNAIL -----------------------------------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tambahkan Thumbnail',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color:  const Color.fromRGBO(40,65,100,1)
                      ),
                    ),
                    IconButton(onPressed: (){
                      _selectThumbnail(context);
                    }, icon: thumbnail == null?  Icon(Icons.add, color:
                    Color.fromRGBO(40,65,100,1),) : Icon(Icons.edit_rounded, color:
                    Color.fromRGBO(40,65,100,1),)),
                  ],
                ),
                //ImagePreview()
                thumbnail == null? Container(
                  margin: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'Tidak ada thumbnail yang dipilih',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.black
                      ),
                    ),
                  ),
                ):SizedBox(
                  height: 180,

                    child : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onLongPress: (){
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                  title: Text(
                                    'Apakah Anda ingin menghapusnya?',
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Colors.black
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      child: Text('Batal'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Hapus'),
                                      onPressed: () {
                                        setState(() {
                                          thumbnail == null;
                                        });
                                        Navigator.of(context).pop();
                                      },
                                    ),]
                              );
                            });
                          },
                          child: AspectRatio(
                            aspectRatio: 4/3,
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: Colors.blue,
                                      width: 2
                                  )
                              ),
                              child: Image.memory(
                                thumbnail!, height: double.infinity, width:double.infinity,
                                fit:  BoxFit.cover,),
                            ),
                          ),
                        ),
                      )
                ),
                const SizedBox(height: 5,),

            // ------------------------------- LOKASI---------------------------------------------

                Text(
                  'Tambahkan Lokasi Kejadian',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color:  const Color.fromRGBO(40,65,100,1)
                  ),
                ),
                const SizedBox(height: 14,),
                LocationWidget(onSelected: (location){
                  userLocation = location;
                  ref.read(locationRemember.notifier).state = userLocation;
                }),
                SizedBox(height: 14,),
                // -------------------------------------------- WAKTU ----------------------------------------
                Text(
                  'Tambahkan Waktu Kejadian',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color:  const Color.fromRGBO(40,65,100,1)
                  ),
                ),

                Container(
                  margin: const EdgeInsets.symmetric(vertical: 20),
                    child: CoolDateTimePicker(onSelectedDate: (date){
                      dateTimeSelected = date;
                    },
                    onSelectedTime: (time){
                      timeOfDaySelected = time;
                    },)),

                /// ---------------------------------------- KORBAN ---------------------------------
                Text(
                  'Korban',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color:  const Color.fromRGBO(40,65,100,1)
                  ),
                ),
                Container(
                  constraints: BoxConstraints(maxWidth: 550),
                  margin: EdgeInsets.only(top:16),
                  child: TextFormField(
                    initialValue: victimName,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLines: 2,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color.fromRGBO(40,65,100,1) ),
                    decoration: InputDecoration(
                        hintText: 'Tuliskan nama korban...',
                        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color.fromRGBO(67,101,109,1)
                        ),
                        filled:  true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                        )
                    ),
                    onChanged: (value) {
                        victimName = value;
                        ref.read(namaKorbanRememberProvider.notifier).state = value;
                    },
                    onSaved: (value){
                      victimName = value;
                    },
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top:16),
                  child: TextFormField(
                    onChanged: (value){
                      victimDetail = value;
                      ref.read(keteranganKorbanRememberProvider.notifier).state = value;
                    },
                    onSaved: (value){
                      victimDetail = value;
                    },
                    initialValue: victimDetail,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    maxLines: 7,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: const Color.fromRGBO(40,65,100,1) ),
                    decoration: InputDecoration(
                        hintText: 'Tuliskan keterangan korban',
                        hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Color.fromRGBO(67,101,109,1)
                        ),
                        filled:  true,
                        fillColor: Color.fromRGBO(240, 240, 240, 1),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none
                        )
                    ),

                  ),
                ),
              ],
            ),
          ),
        ) :





           Padding(
          padding: EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Judul',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color.fromRGBO(40, 65, 100, 1),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 16),
                        constraints: BoxConstraints(maxWidth: 550),
                        child: TextFormField(
                          initialValue: title,
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          keyboardType: TextInputType.name,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Anda belum memasukkan judul kasus';
                            }
                          },
                          onSaved: (value){
                            title = value;
                          },
                          onChanged: (value){
                            if(value!=null){
                              title =value;
                              ref.read(titleRememberProvider.notifier).state = value;
                            }
                          },
                          maxLines: 2,
                          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: const Color.fromRGBO(40, 65, 100, 1),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Tuliskan judul kasus...',
                            hintStyle:
                            Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Color.fromRGBO(67, 101, 109, 1),
                            ),
                            filled: true,
                            fillColor: Color.fromRGBO(240, 240, 240, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: const Color.fromRGBO(40, 65, 100, 1),
                            ),
                          ),
                          IconButton(onPressed: (){
                            ref.read(categoryExtendedProvider.notifier).state = !ref.read(categoryExtendedProvider.notifier).state;
                          }, icon: Icon(!isExtendedCategory? Icons.add : Icons.minimize, color:
                          const Color.fromRGBO(40,65,100,1),))
                        ],
                      ),
                      SizedBox(height: 10),
                      CategorySelection(),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              'Deskripsi',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: const Color.fromRGBO(40, 65, 100, 1),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: TextFormField(
                initialValue: description,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Tolong tuliskan deskripsi kasus yang ingin Anda unggah';
                  }
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLines: 7,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: const Color.fromRGBO(40, 65, 100, 1),
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan deskripsi kasus...',
                  hintStyle:
                  Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Color.fromRGBO(67, 101, 109, 1),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(240, 240, 240, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                 description = value;
                 ref.read(deskripsiRememberProvider.notifier).state = value;
                },
                onSaved: (value){
                  description = value;
                },
              ),
            ),
            SizedBox(height: 20),



            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tambahkan Bukti',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: const Color.fromRGBO(40, 65, 100, 1),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _selectImage(context);
                            },
                            icon: Icon(
                              Icons.add,
                              color: Color.fromRGBO(40, 65, 100, 1),
                            ),
                          ),
                        ],
                      ),
                      horizontalViewList.isEmpty
                          ? Container(
                        margin: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Mohon upload bukti kasus jika tersedia',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: 180,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: horizontalViewList.length,
                          itemBuilder: (ctx, idx) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onLongPress: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Mohon upload bukti kasus jika tersedia',
                                          style:
                                          Theme.of(context).textTheme.bodyMedium!.copyWith(
                                            color: Colors.black,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: Text('Batal'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                          TextButton(
                                            child: Text('Hapus'),
                                            onPressed: () {
                                              setState(() {
                                                horizontalViewList.removeAt(idx);
                                              });
                                              Navigator.of(context).pop();
                                            },
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.blue,
                                      width: 2,
                                    ),
                                  ),
                                  child: Image.memory(
                                    horizontalViewList[idx],
                                    height: 150,
                                    width: 150,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),// bukti

                SizedBox(width: 48,),
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tambahkan Thumbnail',
                            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: const Color.fromRGBO(40, 65, 100, 1),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              _selectThumbnail(context);
                            },
                            icon: thumbnail == null
                                ? Icon(Icons.add, color: Color.fromRGBO(40, 65, 100, 1))
                                : Icon(Icons.edit_rounded, color: Color.fromRGBO(40, 65, 100, 1)),
                          ),
                        ],
                      ),
                      thumbnail == null
                          ? Container(
                        margin: EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'Tidak ada thumbnail yang dipilih',
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Colors.black,
                            ),
                          ),
                        ),
                      )
                          : SizedBox(
                        height: 180,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onLongPress: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text(
                                      'Apakah Anda ingin menghapusnya?',
                                      style:
                                      Theme.of(context).textTheme.bodyMedium!.copyWith(
                                        color: Colors.black,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        child: Text('Batal'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Hapus'),
                                        onPressed: () {
                                          setState(() {
                                            thumbnail = null;
                                          });
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: AspectRatio(
                              aspectRatio: 4 / 3,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2,
                                  ),
                                ),
                                child: Image.memory(
                                  thumbnail!,
                                  height: double.infinity,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ), // Thumbnail
              ],
            ),

            SizedBox(height: 14),
            Divider(
              color: Colors.white60, // Warna garis
              thickness: 2.0, // Lebar garis
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tambahkan Lokasi Kejadian',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color.fromRGBO(40, 65, 100, 1),
                        ),
                      ),
                      SizedBox(height: 14),
                      LocationWidget(onSelected: (location) {
                        userLocation = location;
                      }),
                    ],
                  ),
                ),
                SizedBox(width: 64,),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'Tambahkan Waktu Kejadian',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color.fromRGBO(40, 65, 100, 1),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20),
                        child: CoolDateTimePicker(
                          onSelectedDate: (date) {
                            dateTimeSelected = date;
                          },
                          onSelectedTime: (time) {
                            timeOfDaySelected = time;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Text(
              'Korban',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: const Color.fromRGBO(40, 65, 100, 1),
              ),
            ),
            Container(
              constraints: BoxConstraints(maxWidth: 500),
              margin: EdgeInsets.only(top: 16),
              child: TextFormField(
                initialValue: victimName,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLines: 2,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: const Color.fromRGBO(40, 65, 100, 1),
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan nama korban...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Color.fromRGBO(67, 101, 109, 1),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(240, 240, 240, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  victimName = value;
                  ref.read(namaKorbanRememberProvider.notifier).state = value;
                },
                onSaved:
                  (value){
                    victimName = value;
                  }
                ,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 16),
              child: TextFormField(
                initialValue: victimDetail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                maxLines: 7,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: const Color.fromRGBO(40, 65, 100, 1),
                ),
                decoration: InputDecoration(
                  hintText: 'Tuliskan detail korban...',
                  hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Color.fromRGBO(67, 101, 109, 1),
                  ),
                  filled: true,
                  fillColor: Color.fromRGBO(240, 240, 240, 1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value){
                victimDetail = value;
                ref.read(keteranganKorbanRememberProvider.notifier).state = value;
                },
                onSaved: (value){
                victimDetail = value;
                },
              ),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    )
      ),
    );
  }
}