import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[50], // Light grey for a softer background
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
    elevation: 0.5,
  ),
  colorScheme: ColorScheme(
    primary: Colors.blue[700]!, // Use a slightly lighter shade of blue for better readability
    onPrimary: Colors.white, // White text/icons on primary
    secondary: Colors.grey[300]!, // Light grey for secondary background elements
    onSecondary: Colors.black87, // Darker text/icons on secondary
    surface: Colors.white, // Card and component background color
    onSurface: Colors.black, // Black text on cards and surfaces
    error: Colors.red,
    onError: Colors.white,
    outline: Colors.grey[400]!, // Subtle outline color
    brightness: Brightness.light,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black87, // Darker text for readability
    displayColor: Colors.black87, // Darker display text
  ),
  iconTheme: IconThemeData(color: Colors.black), // Black icons for consistency
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue[700]!, // Primary blue for FAB
    foregroundColor: Colors.white, // White icon on FAB
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 4.0, // Light shadow for depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0),
    ),
    margin: EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
     backgroundColor: Colors.blue[700], // Background color for buttons
     foregroundColor: Colors.white, // Text color on buttons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100], // Light fill for text fields
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.grey[400]!),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.blue[700]!),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.0),
      borderSide: BorderSide(color: Colors.red),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
    hintStyle: TextStyle(color: Colors.grey[600]),
  ),
);
