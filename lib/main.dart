import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pantau/screen/auth_screen.dart';
import 'package:pantau/screen/mobile_screen..dart';
import 'package:pantau/screen/loading_screen.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/date_symbol_data_local.dart';




void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initializeDateFormatting();

  runApp(ProviderScope(
    child:MaterialApp(
      title: 'Pantau',
      theme: ThemeData().copyWith(
        textTheme: TextTheme(
            titleLarge: GoogleFonts.dosis(
                fontWeight: FontWeight.bold,
                color: const Color.fromRGBO(40,65,100,1)
            ),
            titleMedium: GoogleFonts.dosis(
                fontWeight: FontWeight.w300,
                color: const  Color.fromRGBO(107, 107, 107, 1)
            ),
            titleSmall:  GoogleFonts.dosis(
                fontWeight: FontWeight.w300
            ),
            headlineMedium: GoogleFonts.dosis(
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: GoogleFonts.dosis(
              fontWeight: FontWeight.bold,
            ),
            bodyLarge: GoogleFonts.ubuntuCondensed(
              fontWeight: FontWeight.bold
            ),
            bodyMedium: GoogleFonts.ubuntuCondensed(
                fontWeight: FontWeight.bold
            )
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.active){
            if(snapshot.hasData){
              return MobileScreen();
            }
          }
          return LoadingScreen();
        },
      ),
    )
  )
  );
}

