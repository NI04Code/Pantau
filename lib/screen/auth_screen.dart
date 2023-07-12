import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pantau/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pantau/resources/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantau/screen/mobile_screen..dart';

class LoginPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _LoginPageState();
  }
}
class _LoginPageState extends State<LoginPage>{

  final _formKey = GlobalKey<FormState>();
  var _enteredEmailOrUsername = '';
  var _enteredPassword = '';
  bool isLogin = false;

  void _submit() async { // method untuk melakukan validasi akhir sebelum melakukan submit jika valid
   final isValid = _formKey.currentState!.validate();
   if(isValid){
     _formKey.currentState!.save();
     setState(() {
       isLogin = ! isLogin;
     });
     String res = await Auth.instance.loginUser(identifier: _enteredEmailOrUsername, password: _enteredPassword);
     if(res == 'success'){
        setState(() {
          isLogin = ! isLogin;
        });
         Navigator.pushReplacement(
         context,
         MaterialPageRoute(builder: (context) => MobileScreen()),
       );
         return;

     }
     setState(() {
       isLogin = !isLogin;
     });
     ScaffoldMessenger.of(context).clearSnackBars();
     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Terjadi kesalahan saat mencoba masuk')));

   }
  }
  @override
  Widget build(BuildContext context) {
    
    // TODO: implement build
    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.only(top: 0,left: 10,right: 10, bottom: 0),
          child: SingleChildScrollView(
            child:
              Column(
                //mainAxisSize: MainAxisSize.min,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 72),
                    child: Column(
                      children: [
                        Image.asset('asset/logo-pantau.png', width: 140, height: 140,),
                        Text('Pantau',
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Colors.black, fontSize: 24), textAlign: TextAlign.center,),
                        const SizedBox(height: 8,),
                        Text('Bersama Mewujudkan Keadilan',
                          style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 20), textAlign: TextAlign.center,),
                      ],
                    ),
                  ), //Logo, nama, subtitle
              SizedBox(height: 28,),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400
                ),
                child: Container(
                  padding: EdgeInsets.symmetric( vertical:  20),

                  child: Form(
                    key: _formKey,// form terintegrasi untuk login
                    child: Wrap(
                      runSpacing: 24,
                      children: [
                        TextFormField( // textfield untuk username atau email
                          onSaved: (value){
                            _enteredEmailOrUsername = value!;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration:  InputDecoration(
                            labelText: "Email / Username",
                            filled:  true,
                            fillColor: Color.fromRGBO(240, 240, 240, 1),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none
                            )
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value){
                            if(value == null || value.trim().isEmpty){
                              return "Anda belum memasukkan email atau username";
                            }
                          },

                        ),
                        TextFormField(// textfield untuk password
                          onSaved: (value){
                            _enteredPassword = value!;
                          },
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          decoration:  InputDecoration(
                              labelText: "Kata Sandi",
                              filled:  true,
                              fillColor: Color.fromRGBO(240, 240, 240, 1),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none
                              )
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          obscureText: true,
                          validator: (value){
                            if(value == null || value.trim().length < 6){
                              return "Kata sandi harus memiliki setidaknya 6 karakter";
                            }
                          },

                        )
                      ],
                    ),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: Container(
                  margin: EdgeInsets.only(bottom: 10),
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton( // Button untuk melakukan login ke aplikasi
                    onPressed: _submit ,
                    child: ! isLogin?  Text('Masuk') : CircularProgressIndicator(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  Color.fromRGBO(37, 124, 225, 1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                  )
                )
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Text('Belum mempunyai akun? ', style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                     color: Colors.black
                   ),),
                  TextButton(onPressed: (){
                    Navigator.of(context).push(MaterialPageRoute(builder: (ctx){
                      return const RegisterPage();
                    }));
                  }, child: const Text('Daftar')),
                ],
              )
            ,
  ]),
        ),
      ),
    ));
  }
}

class RegisterPage extends StatefulWidget{
  const RegisterPage({super.key});
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _RegisterPageState();
  }
}

class _RegisterPageState extends State<RegisterPage>{

  final _formKey = GlobalKey<FormState>();
  var _enteredUsername = '';
  var _enteredFullName = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _reEnteredPassword = '';
  bool _obscureTextPassword = true;
  bool _obscureTextReEnteredPassword = true;

  void _register() async {
    final isValid = _formKey.currentState!.validate();
    if(isValid){
      _formKey.currentState!.save();

        final auth = Auth.instance;
        final res = await auth.signUpUser(username: _enteredUsername, fullName: _enteredFullName, email: _enteredEmail, password: _enteredPassword);

        if( res == 'success'){
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
          Text('Berhasil mendaftarkan pengguna',)));
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:
        Text('Terjadi kesalahan dalam mendaftarkan pengguna')));
      }
    }





  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black, weight: 96, size: 30),
        backgroundColor: Colors.white,
        title: Text('Buat Akun', style: Theme.of(context).textTheme.headlineSmall!.copyWith(
          color: Colors.black
        )),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0,horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(left:  10,top: 10),
                  child: Text('Halo Pemantau Baru!',
                    style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      color: Colors.black
                    ),),
                ),
                SizedBox(height: 24,),
                Form(
                  key: _formKey,
                  child:
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Container(

                      width: double.infinity,
                      child: Wrap(
                        runSpacing: 24,
                        children: [
                          TextFormField( // textfield untuk username
                            onSaved: (value){
                              _enteredUsername = value!;
                            },
                            decoration:  InputDecoration(
                                labelText: "Username",
                                filled:  true,
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none
                                )
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value){
                              if(value == null || value.trim().isEmpty){
                                return "Anda belum memasukkan username";
                              }
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,

                          ),
                          TextFormField( // textfield untuk nama lengkap
                            onSaved: (value){
                              _enteredFullName = value!;
                            },
                            decoration:  InputDecoration(
                                labelText: "Nama Lengkap",
                                filled:  true,
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none
                                )
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value){
                              if(value == null || value.trim().isEmpty){
                                return "Anda belum memasukkan nama lengkap";
                              }
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,

                          ),
                          TextFormField( // textfield untuk email
                            onSaved: (value){
                              _enteredEmail = value!;
                            },
                            decoration:  InputDecoration(
                                labelText: "Email",
                                filled:  true,
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none
                                )
                            ),
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value){
                              if(value == null || value.trim().isEmpty){
                                return "Anda belum memasukkan email";
                              }
                              if(! value.contains('@')){
                                return "Email tidak valid";
                              }
                            },
                            autovalidateMode: AutovalidateMode.onUserInteraction,

                          ),
                          TextFormField( // textfield untuk kata sandi
                            onSaved: (value){
                              _enteredPassword = value!;
                            },
                            onChanged: (value){
                              setState(() {
                                _enteredPassword = value;

                              });
                            },
                            decoration:  InputDecoration(
                                labelText: "Kata Sandi",
                                filled:  true,
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none
                                ),
                              suffixIcon: IconButton(
                                icon: _obscureTextPassword? Icon(Icons.visibility_off):
                                Icon(Icons.visibility),
                                onPressed: (){
                                  setState(() {
                                    _obscureTextPassword = ! _obscureTextPassword;
                                  });
                                },),
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            obscureText: _obscureTextPassword,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value){
                              if(value == null || value.trim().isEmpty){
                                return "Anda belum menambahkan kata sandi";
                              }

                            },

                          ),
                          TextFormField( // textfield untuk password ulang
                            onSaved: (value){
                              _reEnteredPassword = value!;
                            },
                            onChanged: (value){
                              setState(() {
                                _reEnteredPassword = value;
                              });
                            },
                            decoration:  InputDecoration(
                              suffixIcon: IconButton(
                                icon: _obscureTextReEnteredPassword? Icon(Icons.visibility_off):
                                Icon(Icons.visibility),
                                onPressed: (){
                                  setState(() {
                                    _obscureTextReEnteredPassword = ! _obscureTextReEnteredPassword;
                                  });
                                },),
                                labelText: "Masukkan Ulang Kata Sandi",
                                filled:  true,
                                fillColor: Color.fromRGBO(240, 240, 240, 1),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none
                                )
                            ),
                            keyboardType: TextInputType.text,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            obscureText: _obscureTextReEnteredPassword,
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (value){
                              if(value == null || value.trim().isEmpty){
                                return "Anda belum memasukkan ulang kata sandi";
                              }
                              if(_enteredPassword != _reEnteredPassword){
                                return "Anda memasukkan password yang tidak sama";
                              }
                            },

                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Container(
                      margin: EdgeInsets.only(bottom: 10),
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton( // Button untuk melakukan login ke aplikasi
                          onPressed: _register,
                          child: const  Text('Daftar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:  Color.fromRGBO(37, 124, 225, 1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          )
                      )
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}