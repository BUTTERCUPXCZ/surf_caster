import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add this import for Get to work
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/PAGES/Home_page.dart';
import 'package:surf_caster/PAGES/profile.dart';
import 'package:surf_caster/auth/auth.dart';
import 'package:surf_caster/auth/login_or_register.dart';
import 'package:surf_caster/theme/light_mode.dart'; 
import 'package:surf_caster/COMPONENTS/MainScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: GetMaterialApp( // Change to GetMaterialApp
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        home: Auth(),
        theme: lightmode,
        routes: {
          '/login_or_register': (context) => LoginOrRegister(),
          '/Home_page': (context) => HomePage(),
          '/profile': (context) => ProfilePage(),
        },
      ),
    );
  }
}

class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child; // Removes the overscroll glow effect
  }
}
