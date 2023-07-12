import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:pantau/models/user.dart';
import 'package:pantau/screen/other_user_profile_page.dart';

class UserListTile extends StatelessWidget {
  final User user;

  const UserListTile({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:  EdgeInsets.symmetric(horizontal: 8),
      decoration:  BoxDecoration(
        color:  Colors.blue.shade200,
        borderRadius: BorderRadius.circular(10)
      ),
      child: ListTile(onTap:(){
        print('hereeee');
        Navigator.of(context).push(MaterialPageRoute(builder: (context){
          return OtherUserProfilePage(user: user);
        }));
      },
        leading: user.photoUrl!.isNotEmpty? CircleAvatar(
          backgroundImage: NetworkImage(user.photoUrl!)
        ): CircleAvatar(
          child: Icon(Icons.person_rounded),
          backgroundColor: Colors.grey,
        ),
        title: Text(
          user.name,
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        subtitle: Text(user.bio.isEmpty? 'Tidak ada bio' :
          user.bio,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w200
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.message),
          onPressed: () {
            // Aksi ketika tombol pesan di tekan
          },
        ),

      ),
    );
  }
}