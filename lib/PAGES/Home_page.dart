import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:surf_caster/PAGES/CreatePost.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/PAGES/WaveCondtionScreen.dart';
import 'package:surf_caster/PAGES/favoritespage.dart';
import 'package:surf_caster/helper/favoriteNotifier.dart';
import 'package:surf_caster/service/database.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Stream? postStream;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  Map<String, bool> favoriteStatus = {};
  String searchQuery = "";
  List<Map<String, dynamic>> allPosts = [];
  List<Map<String, dynamic>> filteredPosts = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadPostStream(); 
    
  }
  @override
  void dispose(){
    searchController.dispose();
    super.dispose();
  }
  void searchPosts(String query) {
  setState(() {
    searchQuery = query;
  });
}

  void openFavoritesPage() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FavoritesPage()),
    );
  }

 
 // Search logic
  void searchPost(String query) {
    setState(() {
      if(query.isEmpty){
       filteredPosts = allPosts;
      }else{
        filteredPosts = allPosts
        .where((post)=>
        post['Location']!.toLowerCase().contains(query.toLowerCase())).toList();
      }
    });
  }



  Future<void> loadPostStream() async {
    postStream = await DatabaseMethods().getPostDetails();

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users') // Update collection name if necessary
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      Map<String, dynamic>? userData = userDoc.data() as Map<String, dynamic>?;
      List<String> favoriteIds = userData?['favorites']?.cast<String>() ?? [];

      setState(() {
        favoriteStatus = {for (var id in favoriteIds) id: true};
      });
    } else {
      setState(() {
        favoriteStatus = {};
      });
      print("User document does not exist. No favorites loaded.");
    }
  }

  Future<void> toggleFavorite(DocumentSnapshot ds) async {
  String postID = ds.id;
  bool isCurrentlyFavorited = favoriteStatus[postID] ?? false;
  DocumentReference userRef =
      FirebaseFirestore.instance.collection('Users').doc(currentUserId);

  if (isCurrentlyFavorited) {
    userRef.update({
      'favorites': FieldValue.arrayRemove([postID])
    });
    Provider.of<Favoritenotifier>(context, listen: false).removeFavorite(postID);
  } else {
    userRef.update({
      'favorites': FieldValue.arrayUnion([postID])
    });
    Provider.of<Favoritenotifier>(context, listen: false).addFavorite(postID);
  }

  setState(() {
    favoriteStatus[postID] = !isCurrentlyFavorited;
  });
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

  Future<void> deleteData(BuildContext context, DocumentSnapshot ds) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete'),
        content: const Text("Do you want to delete this post?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('Post').doc(ds.id).delete();
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Future<void> editPost(DocumentSnapshot ds) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreatePost(
          postId: ds.get('Id'),
          initialName: ds.get('Name'),
          initialLocation: ds.get('Location'),
          initialLevel: ds.get('Difficulty Level'),
        ),
      ),
    );
  }

  Widget buildPostCard(DocumentSnapshot ds) {
  String postID = ds.id;

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
            Row(
              children: [
                Text(
                  "Posted by: ${ds["Username"]}",
                  style: TextStyle(
                    color: Colors.blueGrey.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (ds["userId"] == currentUserId)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onSelected: (String value) {
                      if (value == 'Edit') {
                        editPost(ds);
                      } else if (value == 'Delete') {
                        deleteData(context, ds);
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem<String>(
                        value: 'Edit',
                        child: Text('Edit Post'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'Delete',
                        child: Text('Delete Post'),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10.0),
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
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 4.0),
            Text(
              "Difficulty Level: ${ds["Difficulty Level"]}",
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 10.0),
            // Consumer for Favorite Button
             Consumer<Favoritenotifier>(
  builder: (context, favoritesNotifier, child) {
    bool isFavorite = favoritesNotifier.favoritePostIds.contains(postID);

    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
      onPressed: () async {
        if (isFavorite) {
          // Remove from favorites
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .update({
            'favorites': FieldValue.arrayRemove([postID]),
          });
          favoritesNotifier.removeFavorite(postID);
        } else {
          // Add to favorites
          await FirebaseFirestore.instance
              .collection('Users')
              .doc(currentUserId)
              .update({
            'favorites': FieldValue.arrayUnion([postID]),
          });
          favoritesNotifier.addFavorite(postID);
        }
      },
    );
  },
),
          ],
        ),
      ),
    ),
  );
}


 Widget buildPostList() {
  return Column(
    children: [
      // Search Bar with Button
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search by location",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                 FocusScope.of(context).unfocus();

                setState(() {
                  searchQuery = searchController.text.trim();
                });
              },
              child: const Text("Search"),
            ),
          ],
        ),
      ),

      // Posts
      Expanded(
        child: StreamBuilder(
          stream: postStream,
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              // Use all posts initially
              List<DocumentSnapshot> posts = snapshot.data.docs;

              // Apply search query filter
              if (searchQuery.isNotEmpty) {
                posts = posts.where((doc) {
                  String location = doc["Location"]?.toLowerCase() ?? "";
                  return location.contains(searchQuery.toLowerCase());
                }).toList();
              }

              if (posts.isEmpty) {
                return Center(child: Text("No posts found"));
              }

              return ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = posts[index];
                  return buildPostCard(ds);
                },
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        ),
      ),
    ],
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    floatingActionButton: FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreatePost()),
        );
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      child: const Icon(Icons.add, color: Colors.white),
    ),
    body: Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: buildPostList(), // Updated with search bar
          ),
        ),
      ],
    ),
  );
}

}

