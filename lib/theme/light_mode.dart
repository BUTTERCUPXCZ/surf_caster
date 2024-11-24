import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[100], // Softer background with minimal contrast
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black87), // Slightly softer black for minimalism
    titleTextStyle: TextStyle(
      color: Colors.black87, 
      fontSize: 20, 
      fontWeight: FontWeight.w600, // Slightly lighter weight
    ),
    elevation: 0.2, // Subtle elevation for a modern touch
  ),
  colorScheme: ColorScheme(
    primary: Colors.blue[600]!, // Refined, muted blue for a minimalist look
    onPrimary: Colors.white, // White text/icons on primary
    secondary: Colors.grey[200]!, // Very light grey for secondary elements
    onSecondary: Colors.black87, // Black text/icons on secondary
    surface: Colors.white, // Pure white for cards and components
    onSurface: Colors.black87, // Softer black text for surfaces
    error: Colors.red[400]!, // Subtle error red
    onError: Colors.white,
    outline: Colors.grey[300]!, // Minimal outline
    brightness: Brightness.light,
  ),
  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black87, // Darker text for readability
    displayColor: Colors.black87, // Consistent display color
  ),
  iconTheme: IconThemeData(color: Colors.black87), // Slightly softened black icons
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue[600]!, // Muted blue for FAB
    foregroundColor: Colors.white, // White icons on FAB
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 3.0, // Subtle shadow for depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Consistent curve
    ),
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.blue[600], // Minimalist blue for buttons
      foregroundColor: Colors.white, // White text/icons
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6.0), // Subtle curve
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[100], // Light fill for text fields
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.grey[300]!), // Minimal border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.blue[600]!),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.0),
      borderSide: BorderSide(color: Colors.red[400]!),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    hintStyle: TextStyle(color: Colors.grey[600]), // Subtle grey hint
  ),
);
