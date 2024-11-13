import 'package:flutter/material.dart';

class textfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final String? helperText; // Added helperText parameter
  final Widget? suffixIcon; // Added suffixIcon parameter

  const textfield({
    super.key,
    required this.hintText,
    required this.obscureText,
    required this.controller,
    this.helperText,  // Made helperText optional
    this.suffixIcon,  // Made suffixIcon optional
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        hintText: hintText,
        helperText: helperText,  // Display helperText below the field
        suffixIcon: suffixIcon,  // Display suffixIcon (e.g., password visibility toggle)
      ),
    );
  }
}
