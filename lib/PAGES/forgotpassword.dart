import 'package:flutter/material.dart';
import 'package:surf_caster/auth/authservices.dart';

class Forgotpassword extends StatefulWidget{
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  final _auth = Authservices();
 final email = TextEditingController();


   @override
   Widget build(BuildContext context){
     return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        elevation: 0,
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
         crossAxisAlignment: CrossAxisAlignment.stretch,
         children: [
          Text(
            'Reset Your Password',
            style:  TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          Text('Enter your email address and we will send you a link to reset your password.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
          textAlign: TextAlign.center,
          ),
          SizedBox(height: 30),

          TextField(
           controller: email,
           decoration: InputDecoration(
            labelText: 'Emial Address',
            prefixIcon: Icon(Icons.email),
             
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10)
            ),
           ),
          ),
          SizedBox(height: 20),

          //Submit Button
          ElevatedButton(
            onPressed: () async {
           await _auth.sendPasswordReset(email.text);
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Email has been sent successfully, Please check your email")));
           
           Navigator.pop(context);
            },
            child: Text(
              'Send Reset Link',
              style: TextStyle(fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
            ),
          ),
          SizedBox(height: 20),

          //Back to Login
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
           child: Text('Back to Login',
            style: TextStyle(color: Theme.of(context).colorScheme.onSecondary),
           ),
           ),
         ],
        ),
      ),
     );
   }
}