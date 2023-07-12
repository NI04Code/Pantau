
import 'package:cloud_firestore/cloud_firestore.dart';
class User{

  String name;
  String uid;
  String bio;
  List following;
  List followers;
  String? photoUrl;
  String? telephoneNumber;
  String username;
  String email;


  User({this.name = '',
    this.uid = '',
    this.following = const [],
    this.photoUrl = '',
    this.followers = const [],
    this.telephoneNumber = '',
    this.username = '',
    this.email = '',
    this.bio = '',
    });

  Map<String, dynamic> convertJSON(){
    return {
      'name' : name,
      'uid' : uid,
      'following' : following,
      'followers' : followers,
      'photo_url' : photoUrl == null? '': photoUrl,
      'telephone_number' : telephoneNumber == null? '':telephoneNumber,
      'username' : username,
      'email' : email,
      'bio' : bio,
    };
  }

  static User buildUser(DocumentSnapshot snapshot){
    var doc = snapshot.data() as Map<String, dynamic>;
    return User(

        bio: doc['bio'],
        email: doc['email'],
        followers: doc['followers'],
        following: doc['following'],
        name: doc['name'],
        telephoneNumber: doc['telephone_number'],
        photoUrl: doc['photo_url'],
        uid: doc['uid'],
        username: doc['username']
    );

  }

  static User fromMap(Map<String, dynamic> doc){
    return User(
        bio: doc['bio'],
        email: doc['email'],
        followers: doc['followers'],
        following: doc['following'],
        name: doc['name'],
        telephoneNumber: doc['telephone_number'],
        photoUrl: doc['photo_url'],
        uid: doc['uid'],
        username: doc['username']
    );
  }
  User copyWith({
    String? name,
    String? uid,
    String? bio,
    List? following,
    List? followers,
    String? photoUrl,
    String? telephoneNumber,
    String? username,
    String? email,
  }) {
    return User(
      name: name ?? this.name,
      uid: uid ?? this.uid,
      bio: bio ?? this.bio,
      following: following ?? this.following,
      followers: followers ?? this.followers,
      photoUrl: photoUrl ?? this.photoUrl,
      telephoneNumber: telephoneNumber ?? this.telephoneNumber,
      username: username ?? this.username,
      email: email ?? this.email,
    );
  }




}