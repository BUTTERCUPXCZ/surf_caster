import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:surf_caster/helper/helper_function.dart';

class UserPage extends StatelessWidget {
 const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("UserPage", style: TextStyle(color: Colors.white),),
      centerTitle: true,
      backgroundColor: Theme.of(context).colorScheme.secondary,
         iconTheme: IconThemeData(
         color: Theme.of(context).colorScheme.inversePrimary, // Matches hamburger icon color
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder(stream: FirebaseFirestore.instance.collection("Users").snapshots(), 
      builder: (context, snapshot){
     //any errors
      if(snapshot.hasError){
        displayMessageToUser("Something went wrong", context);

      }

     //show loading circle
     if(snapshot.connectionState == ConnectionState.waiting){
       return const Center(
        child: CircularProgressIndicator(),
       );
     }

     if(snapshot.data == null){
       return const Text("No data");
     }

     //get all users
      final users = snapshot.data!.docs;


      return ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index){
         //get individual user

         final user = users[index];
         
          return ListTile(
            title:Text( user['username']),
            subtitle: Text( user['email']),
          );
       
        
        }
      );         
      }
      ),
    );
  }
}