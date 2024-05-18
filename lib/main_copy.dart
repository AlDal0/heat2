//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'accueil_copy.dart';
import 'login_screen.dart';
import 'actualite.dart';
import 'resaChambres.dart';
import 'resaRestauration.dart';
import 'mesReservations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // FirebaseAuth.instance
  //     .authStateChanges()
  //     .listen((User? user) {
  //       if (user == null) {

          initializeDateFormatting("fr_FR").then((_) => runApp(
            MaterialApp(
              title: 'Heat',
              debugShowCheckedModeBanner: false,
              initialRoute: '/login',
              theme: ThemeData(
                  useMaterial3: true,
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
                ),
              routes: {
                // When navigating to the "/" route, build the FirstScreen widget.
                '/login': (context) => const LoginScreen(),
                '/accueil': (context) => const Accueil(),
                '/actualite': (context) => const Actualite(),
                '/resachambres': (context) => const ResaChambreHome(),
                '/resarestauration': (context) => const ResaRestauration(),
                '/mesreservations': (context) => const MesReservationsHome(),
              },
            ),
          )
          );
        // } else {
          
        //   initializeDateFormatting("fr_FR").then((_) => runApp(
        //     MaterialApp(
        //       title: 'Heat',
        //       debugShowCheckedModeBanner: false,
        //       initialRoute: '/accueil',
        //       theme: ThemeData(
        //           useMaterial3: true,
        //           colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent),
        //         ),
        //       routes: {
        //         // When navigating to the "/" route, build the FirstScreen widget.
        //         '/login': (context) => const LoginScreen(),
        //         '/accueil': (context) => const Accueil(),
        //         '/actualite': (context) => const Actualite(),
        //         '/resachambres': (context) => const ResaChambreHome(),
        //         '/resarestauration': (context) => const ResaRestauration(),
        //         '/mesreservations': (context) => const MesReservationsHome(),
        //       },
        //     ),
        //   ));

        // }
    //});

}

