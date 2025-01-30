import 'package:flutter/material.dart';
import 'package:film_uygulamasi/screens/home_screen.dart';
import 'package:film_uygulamasi/screens/search_screen.dart';
import 'package:film_uygulamasi/screens/library_screen.dart';
import 'package:film_uygulamasi/screens/profile_screen.dart';
import 'package:film_uygulamasi/screens/browse_screen.dart'; // Göz At ekranı

class NavigationBarScreen extends StatefulWidget {
  const NavigationBarScreen({super.key});

  @override
  NavigationBarScreenState createState() => NavigationBarScreenState();
}

class NavigationBarScreenState extends State<NavigationBarScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(), // Anasayfa
    BrowseScreen(), // Göz At
    const SearchScreen(), // Arama
    const LibraryScreen(), // Listem
    const ProfileScreen(), // Profil
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _pages[_selectedIndex], // Display the selected page
          Positioned(
            bottom: 30, // Yukarıda konumlandırmak için
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 0, 0), // Kırmızı renk
                borderRadius: BorderRadius.circular(30), // Köşeleri yumuşatma
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavItem(Icons.home_outlined, 0),
                  _buildNavItem(Icons.my_library_books_outlined, 1),
                  _buildNavItem(Icons.search_sharp, 2),
                  _buildNavItem(Icons.bookmark_border, 3),
                  _buildNavItem(Icons.person_outlined, 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Icon(
        icon,
        size: 30,
        color: _selectedIndex == index ? Colors.white : Colors.white70,
      ),
    );
  }
}
