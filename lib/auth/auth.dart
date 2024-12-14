import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:surf_caster/COMPONENTS/mainScreen.dart';
import 'package:surf_caster/PAGES/Home_page.dart';
import 'package:surf_caster/auth/login_or_register.dart';

class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder:(context, snapshot) {
            
            //user is logged in
            if(snapshot.hasData){
               return MainScreen();
            }
            else{
              return LoginOrRegister();
            }
        }, 
        ),
    );
  }
}