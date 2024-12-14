import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode searchFocusNode = FocusNode();
  final StreamController<List<DocumentSnapshot>> _streamController = StreamController<List<DocumentSnapshot>>();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    _streamController.close();
    super.dispose();
  }

  Future<void> loadPostStream(String query) async {
    if (query.isEmpty) {
      _streamController.add([]);
      return;
    }

    try {
      String searchQuery = query.toLowerCase();

      final snapshots = FirebaseFirestore.instance.collection('Post').snapshots();

      snapshots.listen((snapshot) {
        final filteredDocs = snapshot.docs.where((doc) {
          String location = doc['Location'].toLowerCase();
          return location.contains(searchQuery);
        }).toList();

        _streamController.add(filteredDocs);
      });
    } catch (e) {
      print("Firestore query error: $e");
      Fluttertoast.showToast(msg: "Error retrieving data.");
    }
  }

  Future<void> openGoogleMap(BuildContext context, String locationName) async {
    try {
      List<Location> locations = await locationFromAddress(locationName);
      if (locations.isNotEmpty) {
        Location loc = locations.first;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Googlemap(
              latitude: loc.latitude,
              longitude: loc.longitude,
              locationName: locationName,
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: "Location not found.");
      }
    } catch (e) {
      print("Error: $e");
      Fluttertoast.showToast(msg: "Error finding location.");
    }
  }

  Widget buildPostCard(DocumentSnapshot ds) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Posted by: ${ds["Username"] ?? 'Unknown'}",
                style: TextStyle(
                  color: Colors.blueGrey.shade700,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                ds["Name"] ?? 'No Name',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4.0),
              GestureDetector(
                onTap: () => openGoogleMap(context, ds["Location"] ?? ''),
                child: Text(
                  "Location: ${ds["Location"] ?? 'Unknown'}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Difficulty Level: ${ds["Difficulty Level"] ?? 'Unknown'}",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPostList() {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: _streamController.stream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          List<DocumentSnapshot> posts = snapshot.data!;

          if (posts.isEmpty) {
            return const Center(child: Text("No posts found."));
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = posts[index];
              return buildPostCard(ds);
            },
          );
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text("Error loading posts."));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (searchFocusNode.hasFocus) {
          searchFocusNode.unfocus();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Unfocus the keyboard before navigating back
              if (searchFocusNode.hasFocus) {
                searchFocusNode.unfocus();
              }
              Navigator.pop(context);
            },
          ),
          title: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(25.0),
            ),
            child: TextField(
              controller: searchController,
              focusNode: searchFocusNode,
              onChanged: (query) => loadPostStream(query.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: "Search Location",
                hintStyle: const TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        body: buildPostList(),
      ),
    );
  }
}
