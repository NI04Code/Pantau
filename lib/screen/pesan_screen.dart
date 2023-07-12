import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pantau/models/message.dart';
import 'package:pantau/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pantau/screen/user_search_new_message.dart';
import 'package:pantau/widgets/search_bar.dart';
import 'package:pantau/models/user.dart';
import 'package:pantau/widgets/bubble_chat.dart';



class ChatElement extends ConsumerWidget{
  final Room room;
   ChatElement({super.key, required this.room});
  DateFormat timeFormat = DateFormat.Hm();
  DateFormat dateFormat = DateFormat.yMd();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  //  room.messages.sort((a,b)=> b.time.compareTo(a.time));
    final user = ref.watch(userProvider);
    final receiver = room.users.firstWhere((element) => element.uid != user.uid);

    // TODO: implement build
    return ListTile(
      title: Text(receiver.name, style: Theme.of(context).textTheme.titleLarge!.copyWith(
        color: Colors.black, fontSize: 20
      ),),
      leading:  receiver.photoUrl!.isNotEmpty? CircleAvatar(radius:  32, backgroundImage: NetworkImage(receiver.photoUrl!),):
      CircleAvatar(
        radius: 32,
        child: Icon(Icons.person_rounded,),
        backgroundColor: Colors.grey,
      ),
      subtitle: Text(room.messages.isEmpty? 'Mulai berbicara dengan ${receiver.name}...' : room.messages.last.uid == user.uid?
      'Anda: ${room.messages.last.chat}' : room.messages.last.chat,
        style:  TextStyle(color: Colors.black,fontSize: 16, fontWeight: FontWeight.w200),
      overflow: TextOverflow.ellipsis,
      maxLines: 2,),
      trailing: Text(room.messages.isEmpty? '':'${timeFormat.format(room.messages.last.time)}\n${dateFormat.format(room.messages.last.time)}', style: TextStyle(color: Colors.black),),
    );
  }
}
class PesanScreen extends ConsumerStatefulWidget{
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _PesanScreenState();
  }
}

class RoomPage extends ConsumerStatefulWidget{

  final Room room;
  const RoomPage({super.key, required this.room});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    // TODO: implement createState
    return _RoomPageState();
  }
}
class _RoomPageState extends ConsumerState<RoomPage>{
  User? receiver;
  TextEditingController _controller = TextEditingController();
  User? sender;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }
  void send()async{
    final user = ref.watch(userProvider);
    Message message = Message(username: user.username, uid: user.uid, chat: _controller.text, time: DateTime.now());
    widget.room.messages.add(message);
    _controller.clear();
    try{
      await FirebaseFirestore.instance.collection('rooms').doc(widget.room.roomId).update(
        {'messages' : FieldValue.arrayUnion([message.toMap()])}
      );
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Berhasil mengirim pesan')));
      setState(() {


      });
    }
    catch(e){
      print(e);
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: Colors.blue,content: Text('Gagal mengirim pesan')));
    }
  }
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    sender = user;
    receiver = widget.room.users.firstWhere((element) => element.uid != sender!.uid);
    // TODO: implement build
    return Scaffold(
      appBar:  AppBar(
        iconTheme: IconTheme.of(context).copyWith(color: Colors.black),
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            receiver!.photoUrl!.isNotEmpty?
            CircleAvatar(
              backgroundImage:  NetworkImage(receiver!.photoUrl!),
            ):
            CircleAvatar(
              child: Icon(Icons.person_rounded,color: Colors.white,),
              backgroundColor: Colors.grey,
            ),
            SizedBox(width: 16,),
            Text(receiver!.name,style:Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black))
          ],
        ),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('rooms').where('roomId', isEqualTo: widget.room.roomId).snapshots(),
        builder: (context, snapshot){

          if(snapshot.connectionState == ConnectionState.waiting){

            return  Column(
              children: [

                 if(widget.room.messages.isEmpty) Expanded(child: Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.black),),)) else
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                          for(final message in widget.room.messages)
                            Container(
                              margin: EdgeInsets.only(bottom: 6),
                              child: ChatBubble(message: message, isSender: message.uid == user.uid,),
                            )
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.grey[200],
                  padding: EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Tulis pesan',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      IconButton(
                        icon: Icon(Icons.send,color: Colors.blue,),
                        onPressed: () {
                          setState(() {
                            send();
                          });

                          // Logika untuk mengirim balasan
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          }
          List<Room> targetedRooms = snapshot.data!.docs.map((e) => Room.fromMap(e.data())).toList();
          final targetedRoom = targetedRooms.first;
          return Column(
            children: [
              if(targetedRoom.messages.isEmpty)Expanded
                (child: Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.black),),))else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      for(final message in targetedRoom.messages)
                        Container(
                          margin: EdgeInsets.only(bottom: 6),
                          child: ChatBubble(message: message, isSender: message.uid == user.uid,),
                        )
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.grey[200],
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: 'Tulis pesan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0),
                    IconButton(
                      icon: Icon(Icons.send,color: Colors.blue,),
                      onPressed: () {
                        setState(() {
                          send();
                        });

                        // Logika untuk mengirim balasan
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
    },
      ),
    );
  }
}

class _PesanScreenState extends ConsumerState<PesanScreen>{
  List<Message> filteredMessages = [];
  final controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    // TODO: implement dispose
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final users = ref.watch(userListProvider);
    // TODO: implement build
    return Scaffold(

      floatingActionButton:
      ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context){
            return UserMessageNewSearch(users: users);
          }));
        },
        child: Icon(Icons.add_comment_rounded, size: 24,),
        style: ElevatedButton.styleFrom(
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
          backgroundColor: Colors.blue, // <-- Button color
        ),
      ),
      appBar: AppBar(
        elevation:  0,
        title:  Text('Pesan', style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Colors.black),),
        backgroundColor:  Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('rooms').where('uid', arrayContains: user.uid).snapshots() ,
        builder: (context, snapshot){
          print('object');
          if(snapshot.connectionState == ConnectionState.waiting ){
            return Column(
              children: [
                SearchBarWidget(onSearch: (strings){ controller.text = strings;}, hintText: 'Cari pesan atau pengguna'),
                Center(
                  child: CircularProgressIndicator(color: Colors.blue,),
                ),
              ],
            );
          }
          List<Room> rooms = snapshot.data!.docs.map((raw) => Room.fromMap(raw.data())).toList() as List<Room>;
          List<Room> roomsCopy = List<Room>.of(rooms).where((element) => element.users.any((element) => element.username.contains(controller.text)) || 
          element.messages.any((element) => element.chat.contains(controller.text))).toList();
          //roomsCopy.where((element) =>  element.uid.contains(controller.text)).toList();

          if(rooms.isEmpty) {return Column(
            children: [
              SearchBarWidget(onSearch: (String){}, hintText: 'Cari pesan atau pengguna'),
              Expanded(child: Center(child: Text('Belum ada pesan', style: TextStyle(color: Colors.black),),)),
            ],
          );}

          if(roomsCopy.isEmpty) {return Column(
            children: [
              SearchBarWidget(onSearch: (string){
                setState(() {
                  controller.text = string;
                });
              }, hintText: 'Cari pesan atau pengguna'),
              Expanded(child: Center(child: Text('Tidak ada pencarian yang sesuai', style: TextStyle(color: Colors.black),),)),
            ],
          );}
          else {return SingleChildScrollView(
            child: Column(
              children: [
                SearchBarWidget(onSearch: (string){
                  setState(() {
                    controller.text = string;
                  });

                }, hintText: 'Cari pesan atau pengguna'),
                if(roomsCopy.isNotEmpty)
                for(final room in roomsCopy)
                  GestureDetector(
                      child: ChatElement(room: room),
                  onTap: (){
                        Navigator.of(context).push(MaterialPageRoute(
                          builder:(context) {
                            return RoomPage(room: room);
                          }
                        ));
                  },)

              ],
            ),
          );}
        },
      ),
    );
  }
}