import 'package:flutter/material.dart';

ThemeData lightmode = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.white,
  scaffoldBackgroundColor: Colors.grey[100], // Light grey background for subtle contrast
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black87), // Black icons for contrast
    titleTextStyle: TextStyle(
      color: Colors.black87,
      fontSize: 18, 
      fontWeight: FontWeight.bold, // Slightly bold for emphasis
    ),
    elevation: 1.0, // Subtle shadow for distinction
  ),
  colorScheme: ColorScheme(
    primary: Colors.black87, // Dark color for primary components
    onPrimary: Colors.white, // White text/icons on primary
    secondary: Colors.grey[200]!, // Very light grey for secondary elements
    onSecondary: Colors.black87, // Black text/icons on secondary
    surface: Colors.white, // White for cards and surfaces
    onSurface: Colors.black87, // Black text for surfaces
    error: Colors.red[400]!, // Subtle red for errors
    onError: Colors.white,
    outline: Colors.grey[300]!, // Light grey outlines for borders
    brightness: Brightness.light,
    background: Colors.grey[100]!, // Background matches scaffold
  ),
  textTheme: TextTheme(
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87), // Slightly bold for readability
    bodyMedium: TextStyle(fontSize: 14, color: Colors.black87), // Normal text
    labelLarge: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[700]), // Secondary labels
  ),
  iconTheme: IconThemeData(color: Colors.black87), // Black icons
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.black87, // Dark FAB
    foregroundColor: Colors.white, // White icons on FAB
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2.0, // Light shadow for depth
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.0), // Rounded corners
    ),
    margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black87, // Dark button
      foregroundColor: Colors.white, // White text/icons
      textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w600), // Clear button text
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0), // Consistent curve
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.grey[200], // Slightly darker fill for text fields
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey[300]!), // Subtle border
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.black87),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.red[400]!),
    ),
    contentPadding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
    hintStyle: TextStyle(color: Colors.grey[600]), // Subtle grey hint
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: Colors.black87,
    unselectedItemColor: Colors.grey[600],
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
    unselectedLabelStyle: TextStyle(fontSize: 11),
  ),
);
