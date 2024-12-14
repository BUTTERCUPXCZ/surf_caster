import 'package:flutter/material.dart';

class Backbutton extends StatelessWidget {
  const Backbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.transparent, // Ensure the background is transparent
        ),
        child: Icon(
          Icons.arrow_back,
          color: Colors.white, // Set the icon color to white
        ),
      ),
    );
  }
}
