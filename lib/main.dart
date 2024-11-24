import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Add this import for Get to work
import 'package:provider/provider.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/PAGES/Home_page.dart';
import 'package:surf_caster/PAGES/forgotpassword.dart';
import 'package:surf_caster/PAGES/profile.dart';
import 'package:surf_caster/auth/auth.dart';
import 'package:surf_caster/auth/login_or_register.dart';
import 'package:surf_caster/helper/favoriteNotifier.dart';
import 'package:surf_caster/theme/light_mode.dart'; 
import 'package:surf_caster/COMPONENTS/MainScreen.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => Favoritenotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: NoGlowScrollBehavior(),
      child: GetMaterialApp( // Change to GetMaterialApp
       debugShowCheckedModeBanner: false,
       scrollBehavior: NoGlowScrollBehavior(), 
        home: Auth(),
        theme: lightmode,
        routes: {
          '/login_or_register': (context) => LoginOrRegister(),
          '/Home_page': (context) => HomePage(),
          '/profile': (context) => ProfilePage(),
          'forgotpassword': (context) => Forgotpassword(),
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
