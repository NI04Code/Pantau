
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pantau/models/user.dart' as Model;
import 'package:uuid/uuid.dart';


class Auth{
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final firebase = FirebaseFirestore.instance;
    static final Auth _instance = Auth();
    final firebaseStorage = FirebaseStorage.instance;

    static Auth get instance{
      return _instance;
    }
    FirebaseAuth get firebaseAuth{
      return _auth;
    }

    Future<String> loginUser({required String identifier, required String password}) async {
      String res = 'success';
      try {
        if (!identifier.contains('@')) {
          final QuerySnapshot snapshot = await firebase.collection('users')
              .where('username', isEqualTo: identifier)
              .get();
          for (QueryDocumentSnapshot data in snapshot.docs) {
            Map<String, dynamic> map = data.data() as Map<String, dynamic>;
            identifier = map['email'];
          }
        }
        await _auth.signInWithEmailAndPassword(email: identifier, password: password);

      }
      catch(e){
        print(e);
        res = "Error";
      }
      print(res);
      return res;
    }

    Future<String> signUpUser({
      required String username,
      required String fullName,
      required String email,
      required String password,
    }) async  {
      String res = 'success';
      try {
        final credential = await _auth.createUserWithEmailAndPassword(
            email: email.trim(), password: password.trim());
        Model.User user = Model.User(name: fullName,
            uid: credential.user!.uid,
            following: [],
            photoUrl: '',
            followers: [],
            username: username,
            email: email,
            bio: '',
            telephoneNumber: '');

        //todo
        await firebase.collection('users').doc(credential.user!.uid).set(user.convertJSON());

      } catch (e) {
        res = 'failed';
      }
      return res;
    }
    Future<String> uploadImageToStorage({required String childName, required Uint8List file, required bool isPost}) async {
      Reference ref = firebaseStorage.ref().child(childName).child(_auth.currentUser!.uid);
      if(isPost){
        String id = const Uuid().v1();
        ref = ref.child(id);
      }
      UploadTask uploadTask = ref.putData(file);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    }


}