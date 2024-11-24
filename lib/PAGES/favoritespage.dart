import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/helper/favoriteNotifier.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  List<DocumentSnapshot> favoritePosts = [];
  bool isLoading = true; // Loading indicator flag

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

  Future<void> removeFavorite(String postId) async {
  bool? confirmDelete = await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete"),
        content: const Text("Are you sure you want to remove this post from your favorites?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text("Delete"),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      );
    },
  );

  if (confirmDelete == true) {
    try {
      // Update Firestore
      DocumentReference userRef = FirebaseFirestore.instance.collection('Users').doc(currentUserId);
      await userRef.update({
        'favorites': FieldValue.arrayRemove([postId])
      });

      // Notify listeners about the change
      Provider.of<Favoritenotifier>(context, listen: false).removeFavorite(postId);

      // Update local state
      setState(() {
        favoritePosts.removeWhere((post) => post.id == postId);
      });
    } catch (e) {
      print("Error removing favorite: $e");
    }
  }
}


  Widget buildFavoritePostCard(DocumentSnapshot ds) {
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
                ds["Name"] ?? "No Name",
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
                  "Location: ${ds["Location"] ?? 'No Location'}",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                "Difficulty Level: ${ds["Difficulty Level"] ?? 'N/A'}",
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 10.0),
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => removeFavorite(ds.id),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUserId)
            .snapshots(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
            return const Center(child: Text("No user data found"));
          }

          List<String> favoritePostIds = List<String>.from(userSnapshot.data!['favorites'] ?? []);

          // Listen to post changes
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('Post')
                .where(FieldPath.documentId, whereIn: favoritePostIds.isNotEmpty ? favoritePostIds : ['dummyId'])
                .snapshots(),
            builder: (context, postSnapshot) {
              if (postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!postSnapshot.hasData || postSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text("No favorite posts found"));
              }

              List<DocumentSnapshot> posts = postSnapshot.data!.docs;

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot post = posts[index];
                  return buildFavoritePostCard(post);
                },
              );
            },
          );
        },
      ),
    );
  }
}
