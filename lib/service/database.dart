// DATABASEMETHODS.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {

  Future<void> createPostDetails(Map<String, dynamic> postDetailsMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Post")
        .doc(id)
        .set(postDetailsMap);
  }

  Stream<QuerySnapshot> getPostDetails() {
    return FirebaseFirestore.instance.collection("Post").snapshots();     
  }

  Future<void> updatePostDetails(Map<String, dynamic> postDetailsMap, String id) async {
    return await FirebaseFirestore.instance
        .collection("Post")
        .doc(id)
        .update(postDetailsMap);
  }

  Future<void> deletePostDetails(String id) async {
    return await FirebaseFirestore.instance
        .collection("Post")
        .doc(id)
        .delete();
  }

 Future<String?> getUsername(String id) async {
  try {
    // Retrieve the user document from Firestore
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('Users') // Ensure the collection name matches Firestore
        .doc(id)
        .get();

    // Safely retrieve and cast data to avoid potential null issues
    final data = userDoc.data() as Map<String, dynamic>?;

    if (data != null && data['username'] != null) {
      return data['username'] as String; // Cast to String to avoid type errors
    } else {
      print("Username field missing or user document does not exist for userId: $id");
      return null; // Return null if username isn't found
    }
  } catch (e) {
    print("Error retrieving username for userId: $id. Error: $e");
    return null;
  }
}


}
