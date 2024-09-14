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
import 'resaSummary.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
//import 'package:flutter_stripe_web/flutter_stripe_web.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
        // your preferred provider. Choose from:
        // 1. Debug provider
        // 2. Device Check provider
        // 3. App Attest provider
        // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  Stripe.publishableKey = "pk_test_51N1cxbEPzWoM6U0uFt3tyFyLmFOIMeCKMop8SR5PRG6h6J5i2MgC0ksKxxuHaCPYF39sXHfziYgNzV4J3XtTmuzj00PxYCcuIp";

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
                  colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo.shade400),
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
                '/resaSummary': (context) => const ResaSummary()
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

