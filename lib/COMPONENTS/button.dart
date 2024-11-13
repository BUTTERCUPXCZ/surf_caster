import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Button extends StatelessWidget {
  final String text;
  final void Function()? onTap;
   
  const Button({
    super.key,
    required this.text,
     required this.onTap,
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
    child: Container(
     decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(12),
     ),
     padding: const EdgeInsets.all(10),
     child: Center(
      child: Text(
        text, 
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
     ),
    ),
    );
    
  }
}