import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:surf_caster/COMPONENTS/textbox.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final userCollection = FirebaseFirestore.instance.collection("Users");
  DateTime? joinedDate;

   @override
  void initState() {
    super.initState();
    fetchJoinedDate();
  }


  Future<void> fetchJoinedDate() async{
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(currentUser.uid).get();
    Timestamp joinedTimeStamp = userDoc['Joined'];
    
    setState(() {
      joinedDate = joinedTimeStamp.toDate();
    });

  }
  

  Future<void> editField(String field, String currentValue) async {
    TextEditingController controller = TextEditingController(text: currentValue);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit $field", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter new $field",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = controller.text.trim();
                if (newValue.isNotEmpty) {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => const Center(child: CircularProgressIndicator()),
                  );
                  await userCollection.doc(currentUser.uid).update({field: newValue});
                  Navigator.pop(context); // Close loading indicator
                }
                Navigator.pop(context); // Close edit dialog
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<User?>(
        future: FirebaseAuth.instance.authStateChanges().first,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (userSnapshot.hasError) {
            return Center(child: Text('Error: ${userSnapshot.error}'));
          }

          if (userSnapshot.hasData) {
            final currentUser = userSnapshot.data;
            final userId = currentUser?.uid;

            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('Users').doc(userId).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.hasData && snapshot.data != null) {
                  final userData = snapshot.data!.data() as Map<String, dynamic>?;

                  if (userData == null || userData.isEmpty) {
                    return const Center(child: Text("User data not found."));
                  }

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ListView(
                      children: [
                        const SizedBox(height: 20),

                        // Profile Picture
                        Center(
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: userData['profileImage'] != null 
                              ? NetworkImage(userData['profileImage']) 
                              : null,
                            child: userData['profileImage'] == null
                              ? const Icon(Icons.person, size: 80, color: Colors.white)
                              : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Username
                        Center(
                          child: Text(
                            userData['username'] ?? 'No username available',
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Joined Date
                        Center(
                          child: joinedDate !=null ?  
                          Text("Joined: ${DateFormat('MMMM y').format(joinedDate!)}",
                          style: const TextStyle(color: Colors.grey),
                          )
                          : CircularProgressIndicator(),
                        ),
                        const SizedBox(height: 40),

                        // Section Title
                        Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            "My Details",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black),
                          ),
                        ),

                        // Email (Editable)
                        Textbox(
                          text: userData['email'],
                          sectionName: 'Email',
                          onPressed: () => editField('email', userData['email']),
                        ),
                        const SizedBox(height: 10),

                        // Bio (Editable)
                        Textbox(
                          text: userData['bio'] ?? 'No bio available',
                          sectionName: 'Bio',
                          onPressed: () => editField('bio', userData['bio'] ?? ''),
                        ),
                      ],
                    ),
                  );
                } else {
                  return const Center(child: Text("No user data available."));
                }
              },
            );
          } else {
            return const Center(child: Text("User is not logged in."));
          }
        },
      ),
    );
  }
}
