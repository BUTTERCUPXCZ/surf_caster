import 'package:flutter/material.dart';
import 'package:surf_caster/PAGES/Login.dart';
import 'package:surf_caster/PAGES/register.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
 State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
//initially show login page
bool showLogin = true;

// toggle between login and register pages
void togglePages(){
  setState(() {
    showLogin = !showLogin;
  });
}

  @override
  Widget build(BuildContext context) {
      if(showLogin){
      return Login(onTap: togglePages);

      }else{
        return Register(onTap: togglePages);
      }

  }
}