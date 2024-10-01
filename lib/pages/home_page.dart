import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ganpatibapa/pages/bottombars/social_feed_screen.dart';
import 'package:ganpatibapa/pages/bottombars/aarti_page.dart';
import 'package:ganpatibapa/pages/bottombars/profile_screen.dart';
import 'package:ganpatibapa/pages/bottombars/search_result_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  late final TextEditingController _searchController;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    _pages = [
      const HomeTab(),
      const VideoFeedScreen(),
      const AartiPostTab(),
      SearchResultsScreen(searchController: _searchController),
      ProfileScreen(uid: FirebaseAuth.instance.currentUser?.uid ?? ''),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 1, 32),
      body: _pages[_selectedIndex], // Display the selected page
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 0, 2, 51),
        selectedItemColor: Colors.yellow[700],
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.video_library),
            label: 'Social',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Aarti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 2, 51),
      appBar: AppBar(
        title: Center(
          child: Text(
            'Saluja\'s Ganpati',
            style: TextStyle(color: Colors.yellow[700]),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 2, 51),
      ),
      body: const Center(
        child: Text('Home', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
