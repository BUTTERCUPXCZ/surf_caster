import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Register extends StatefulWidget {
  final void Function()? onTap;

  const Register({super.key, required this.onTap});

  @override
  State<Register> createState() => _SignUpState();
}

class _SignUpState extends State<Register> {
  // Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  // Error Messages
  String? emailError;
  String? usernameError;
  String? passwordError;
  String? confirmPasswordError;

  // Firestore Helper
  Future<void> addUserToFirestore(User user, String username) async {
    final userId = user.uid;

    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'userId': userId,
        'username': username,
        'Joined': FieldValue.serverTimestamp(),
        'email': user.email,
        'favorites': [],
        'bio': "Your bio here", // Replace with actual bio input if needed
      });
    } catch (e) {
      showErrorDialog("Error adding user to Firestore: $e");
    }
  }

  // Show Error Dialog
  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  // Field Validation Logic
  bool validateFields() {
    setState(() {
      emailError = null;
      usernameError = null;
      passwordError = null;
      confirmPasswordError = null;
    });

    final email = emailController.text.trim();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // Email Validation
    if (email.isEmpty) {
      emailError = "Email is required";
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError = "Please enter a valid email address";
    }

    // Username Validation
    if (username.isEmpty) {
      usernameError = "Username is required";
    } else if (username.length < 3) {
      usernameError = "Username must be at least 3 characters";
    }

    // Password Validation
    if (password.isEmpty) {
      passwordError = "Password is required";
    } else if (password.length < 6) {
      passwordError = "Password must be at least 6 characters long";
    }

    // Confirm Password Validation
    if (confirmPassword.isEmpty) {
      confirmPasswordError = "Please confirm your password";
    } else if (password != confirmPassword) {
      confirmPasswordError = "Passwords do not match";
    }

    //Check if all fields Null
    return emailError == null &&
        usernameError == null &&
        passwordError == null &&
        confirmPasswordError == null;
  }

  // Sign Up Function
  void signUp() async {
    if (!validateFields()) {
      return; // Stop execution if validation fails
    }

    // Show loading indicator
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Add User to Firestore
      User user = userCredential.user!;
      await addUserToFirestore(user, usernameController.text.trim());

      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorDialog(e.message ?? "An error occurred during sign-up");
    }
  }

  // Reusable TextField Builder
  Widget buildTextField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    String? errorText,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            errorText: errorText,
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 15,
              horizontal: 15,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    "assets/new-Logo.png",
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Create Account",
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: 1.2,
                      ),
                ),
                const SizedBox(height: 30),
                // Username
                buildTextField(
                  labelText: "Username",
                  hintText: "",
                  controller: usernameController,
                  errorText: usernameError,
                ),
                // Email
                buildTextField(
                  labelText: "Email",
                  hintText: "",
                  controller: emailController,
                  errorText: emailError,
                ),
                // Password
                buildTextField(
                  labelText: "Password",
                  hintText: "",
                  controller: passwordController,
                  errorText: passwordError,
                  obscureText: true,
                ),
                // Confirm Password
                buildTextField(
                  labelText: "Confirm Password",
                  hintText: "",
                  controller: confirmPasswordController,
                  errorText: confirmPasswordError,
                  obscureText: true,
                ),
                ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                      horizontal: 60,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: Text(
                    "Sign Up",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    GestureDetector(
                      onTap: widget.onTap,
                      child: Text(
                        "Login Here",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
