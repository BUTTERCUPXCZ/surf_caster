import 'package:flutter/material.dart';


class Backbutton extends StatelessWidget {
  const Backbutton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        child: Icon(Icons.arrow_back),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}