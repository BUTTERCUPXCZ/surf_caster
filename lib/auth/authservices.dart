

import 'package:firebase_auth/firebase_auth.dart';

class Authservices {
  final _auth = FirebaseAuth.instance;


   Future<void> sendEmailVerification() async{
   try{
     await _auth.currentUser!.sendEmailVerification();
   }catch(e){
    print(e.toString());
   }


   }

   Future<void> sendPasswordReset(String email) async{
   try{
     await _auth.sendPasswordResetEmail(email:email);
   }catch(e){
    print(e.toString());
   }


   }
}