import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/PAGES/Home_page.dart';
import 'package:surf_caster/PAGES/WaveCondtionScreen.dart';
import 'package:surf_caster/PAGES/favoritespage.dart';
import 'package:surf_caster/PAGES/profile.dart';
import 'package:surf_caster/PAGES/searchpage.dart';
import 'package:surf_caster/main.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    Searchpage(),
    FavoritesPage(),
    WaveConditionScreen(),
    ProfilePage(),
  ];

  // Navigation logic
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Opens the Google Map page
  void _openGoogleMap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Googlemap(
          latitude: 12.8797,
          longitude: 121.7740,
          locationName: "Philippines",
        ),
      ),
    );
  }

  // Logout dialog
  Future<void> _showLogoutDialog() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          _dialogButton("Cancel", () => Navigator.pop(context, false)),
          _dialogButton("Logout", () => Navigator.pop(context, true)),
        ],
      ),
    );
    if (shouldLogout == true) _logout();
  }

  // Handles the logout process
  void _logout() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );
      await FirebaseAuth.instance.signOut();
      Navigator.pop(context); // Close the progress indicator
    } catch (error) {
      Navigator.pop(context); // Close the progress indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $error')),
      );
    }
  }

  // Builds a dialog button with a custom action
  TextButton _dialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  // Builds the AppBar with title and icons
  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar(
      backgroundColor: Colors.white,
      pinned: true, // Subtle shadow color
      title: const Text(
        "SurfCaster",
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        _appBarIcon(Icons.map, _openGoogleMap), // Google Map button
        _appBarIcon(Icons.logout, _showLogoutDialog), // Logout button
      ],
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent, 
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  // Creates an AppBar icon with an action
  IconButton _appBarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.grey[900]),
      onPressed: onPressed,
    );
  }

  // Builds the BottomNavigationBar
  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed, // Set this to fixed to remove glow effect
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
           BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorites'),
        BottomNavigationBarItem(icon: Icon(Icons.waves), label: 'Wave Conditions'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: const Color(0xFF4267B2),
      unselectedItemColor: Colors.grey,
      onTap: _onItemTapped,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(), // SliverAppBar
          SliverFillRemaining(
            child: IndexedStack(
              index: _selectedIndex,
              children: _pages,
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}
