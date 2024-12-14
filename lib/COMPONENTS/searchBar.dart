import 'package:flutter/material.dart';


class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final Future<void> Function(String) onSearch;

  const SearchBar({
    Key? key,
    required this.controller,
    required this.onSearch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: 'Search location (e.g., Mati City)',
        hintStyle: TextStyle(color: Colors.grey[600]),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: Icon(Icons.search, color: Colors.black), // Search icon inside the input field
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
      onSubmitted: (value) {
        if (value.trim().isNotEmpty) {
          onSearch(value.trim());
        }
      },
    );
  }
}
