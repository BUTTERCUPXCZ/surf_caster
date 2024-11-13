import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:surf_caster/service/database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class CreatePost extends StatefulWidget {
  final String? postId;
  final String? initialName;
  final String? initialLocation;
  final String? initialLevel;

  const CreatePost({
    Key? key,
    this.postId,
    this.initialName,
    this.initialLocation,
    this.initialLevel,
  }) : super(key: key);

  @override
  State<CreatePost> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  late TextEditingController nameController;
  late TextEditingController locationController;
  late TextEditingController levelController;
  
  String? username; // Define username here
  String? nameError;
  String? locationError;
  String? levelError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialName ?? '');
    locationController = TextEditingController(text: widget.initialLocation ?? '');
    levelController = TextEditingController(text: widget.initialLevel ?? '');
    
 
    _fetchUsername();
  }

 Future<void> _fetchUsername() async {
    final databaseMethods = DatabaseMethods();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch the username directly using the Firebase Auth UID
    String? fetchedUsername = await databaseMethods.getUsername(userId);
    setState(() {
      username = fetchedUsername ?? "Guest"; // Set to "Guest" if no username found
    });
  }
  Future<void> _uploadData() async {
    setState(() {
      nameError = nameController.text.isEmpty ? 'Please enter a name' : null;
      locationError = locationController.text.isEmpty ? 'Please enter a location' : null;
      levelError = levelController.text.isEmpty ? 'Please enter a difficulty level' : null;
    });

    if (nameError == null && locationError == null && levelError == null) {
      String id = widget.postId ?? randomAlphaNumeric(10);
      String userId = FirebaseAuth.instance.currentUser!.uid; // Get current user ID

      Map<String, dynamic> postDetailsMap = {
        "Name": nameController.text,
        "Location": locationController.text,
        "Id": id,
        "Difficulty Level": levelController.text,
        "Username": username,
        "userId":userId,
        "favorites": [],
      };

      try {
        final databaseMethods = DatabaseMethods();
        if (widget.postId == null) {
          await databaseMethods.createPostDetails(postDetailsMap, id);
          Fluttertoast.showToast(
            msg: "Post created successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        } else {
          await databaseMethods.updatePostDetails(postDetailsMap, id);
          Fluttertoast.showToast(
            msg: "Post updated successfully",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black,
            textColor: Colors.white,
          );
        }
        Navigator.pop(context);
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Failed to save post: $e",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.postId == null ? "Create Post" : "Edit Post",
          style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
        ),
        elevation: 4.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              onPressed: _uploadData,
              child: Text(
                "Save",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username != null && username!.isNotEmpty
              ? "Posting as: $username"
              : "Loading username...",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Name",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter post name',
                errorText: nameError,
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Location",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Enter location',
                errorText: locationError,
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Difficulty Level",
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextFormField(
              controller: levelController,
              decoration: InputDecoration(
                hintText: 'Enter difficulty level',
                errorText: levelError,
                fillColor: Theme.of(context).colorScheme.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
