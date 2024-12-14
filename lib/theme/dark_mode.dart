import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      surface: Colors.grey.shade900,
      primary: const Color.fromARGB(255, 255, 255, 255),
      secondary: const Color.fromARGB(255, 255, 255, 255),
      inversePrimary: Colors.grey.shade300,

    ),
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: Colors.grey[300],
      displayColor: Colors.white
    ),

);