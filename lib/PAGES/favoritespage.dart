import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> favoritePosts = [];
  bool isLoading = true;  // Loading indicator flag

  @override
  void initState() {
    super.initState();
    loadFavoritePosts();
  }

Future<void> loadFavoritePosts() async {
  if (!mounted) return; // Check if the widget is still mounted
  setState(() {
    isLoading = true;
  });
  
  try {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUserId)
        .get();

    if (userDoc.exists && userDoc.data() != null) {
      List<String> favoriteIds = (userDoc.data() as Map<String, dynamic>)['favorites']?.cast<String>() ?? [];

      if (favoriteIds.isNotEmpty) {
        List<QueryDocumentSnapshot> allFavoritePosts = [];

        for (int i = 0; i < favoriteIds.length; i += 10) {
          List<String> batchIds = favoriteIds.sublist(i, i + 10 > favoriteIds.length ? favoriteIds.length : i + 10);

          QuerySnapshot postsSnapshot = await FirebaseFirestore.instance
              .collection('Post')
              .where(FieldPath.documentId, whereIn: batchIds)
              .get();

          allFavoritePosts.addAll(postsSnapshot.docs);
        }

        if (mounted) {
          setState(() {
            favoritePosts = allFavoritePosts;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            favoritePosts = [];
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          favoritePosts = [];
        });
      }
    }
  } catch (e) {
    print("Error loading favorite posts: $e");
    if (mounted) {
      setState(() {
        favoritePosts = [];
      });
    }
  } finally {
    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }
}

@override
void dispose() {
  // Clean up any resources here if needed
  super.dispose();
}


  Future<void> removeFavorite(String postId) async {
  bool? confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Delete"),
        content: Text("Are you sure you want to remove this post from your favorites?"),
        actions: [
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false); // Return false if canceled
            },
          ),
          TextButton(
            child: Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop(true); // Return true if confirmed
            },
          ),
        ],
      );
    },
  );

  // Check if the user confirmed the deletion
  if (confirmDelete == true) {
    DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(currentUserId);

    // Fetch current user's favorites
    DocumentSnapshot userDoc = await userRef.get();
    List<String> favorites = List.from(userDoc['favorites'] ?? []);

    // Remove the post ID from the favorites list
    favorites.remove(postId);

    // Update the user's favorites in Firestore
    await userRef.update({'favorites': favorites});

    // Update the local list of favorite posts in the app's state
    setState(() {
      favoritePosts.removeWhere((post) => post.id == postId);
    });
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



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())  // Show loading indicator
          : favoritePosts.isEmpty
              ? const Center(child: Text("No favorite posts found"))
              : ListView.builder(
                  itemCount: favoritePosts.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot post = favoritePosts[index];
                    return buildFavoritePostCard(post);
                  },
                ),
    );
  }

  Widget buildFavoritePostCard(DocumentSnapshot ds) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
    child: Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ds["Name"],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4.0),
                GestureDetector(
                  onTap: () => openGoogleMap(context, ds["Location"]),
                  child: Text(
                    "Location: ${ds["Location"]}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  "Difficulty Level: ${ds["Difficulty Level"]}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Positioned delete button in the upper right corner
          Positioned(
            right: 8.0,
            top: 8.0,
            child: IconButton(
              onPressed: () => removeFavorite(ds.id),
              icon: Icon(Icons.delete, color: Colors.red),
            ),
          ),
        ],
      ),
    ),
  );
}
}