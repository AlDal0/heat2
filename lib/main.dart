//import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home.dart';
import 'loginScreen.dart';
import 'news.dart';
import 'resaHome.dart';
import 'menu.dart';
import 'room.dart';
import 'myResaHome.dart';
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
                '/home': (context) => const Accueil(),
                '/news': (context) => const Actualite(),
                '/resaHome': (context) => const ResaHome(),
                '/menus': (context) => const MenuHome(),
                '/rooms': (context) => const RoomHome(),
                '/myResaHome': (context) => const MyResaHome(),
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

