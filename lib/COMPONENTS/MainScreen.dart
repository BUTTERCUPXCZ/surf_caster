import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surf_caster/PAGES/Googlemap.dart';
import 'package:surf_caster/PAGES/Home_page.dart';
import 'package:surf_caster/PAGES/WaveCondtionScreen.dart';
import 'package:surf_caster/PAGES/favoritespage.dart';
import 'package:surf_caster/PAGES/profile.dart';
import 'package:surf_caster/PAGES/searchpage.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  bool _isKeyboardVisible = false;
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomePage(),
    Googlemap(
      latitude: 12.8797,
      longitude: 121.7740,
      locationName: "Philippines",
    ),
    FavoritesPage(),
    WaveConditionScreen(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Add the observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Remove the observer
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Check if the keyboard is visible by comparing viewInsets.bottom
    final bottomInset = WidgetsBinding.instance.window.viewInsets.bottom;
    setState(() {
      _isKeyboardVisible = bottomInset > 0.0;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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

  TextButton _dialogButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // Dismiss the keyboard
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                slivers: [
                  if (_selectedIndex != 1)
                    SliverAppBar(
                      backgroundColor: const Color.fromARGB(255, 30, 30, 30),
                      elevation: 0,
                      title: Text(
                        _getAppBarTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      iconTheme: const IconThemeData(color: Colors.white),
                      actions: [
                        if (_selectedIndex == 0)
                          IconButton(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Searchpage(),
                                ),
                              );
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: _showLogoutDialog,
                        ),
                      ],
                      systemOverlayStyle: const SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light,
                      ),
                    ),
                  SliverFillRemaining(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeBottom: true,
                      child: IndexedStack(
                        index: _selectedIndex,
                        children: _pages,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Conditionally display the BottomNavigationBar
        bottomNavigationBar: _isKeyboardVisible ? null : _buildBottomNavigationBar(),
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0: // Home
        return "SurfCaster";
      case 2: // Favorites
        return "Favorites";
      case 3: // Wave Conditions
        return "Wave Conditions";
      case 4: // Profile
        return "Profile";
      default: // Other pages (e.g., Explore/GoogleMap)
        return "";
    }
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      iconSize: 27,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home_1),
          activeIcon: Icon(Iconsax.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.location),
          activeIcon: Icon(Iconsax.location_add),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.heart),
          activeIcon: Icon(Iconsax.heart5),
          label: 'Favorites',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.cloud_drizzle),
          activeIcon: Icon(Iconsax.cloud_drizzle5),
          label: 'Wave',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.user),
          activeIcon: Icon(Iconsax.user),
          label: 'Profile',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey[500],
      backgroundColor: Colors.white,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
      unselectedLabelStyle: const TextStyle(fontSize: 11),
      onTap: _onItemTapped,
    );
  }
}
