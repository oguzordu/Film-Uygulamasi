import 'package:flutter/material.dart';
import 'package:film_uygulamasi/screens/genre_movie_list_screen.dart';

class BrowseScreen extends StatelessWidget {
  BrowseScreen({super.key});

  final List<Map<String, dynamic>> genres = [
    {
      'id': 28,
      'name': 'Aksiyon',
      'icon': Icons.local_fire_department,
      'color': Colors.red
    },
    {
      'id': 35,
      'name': 'Komedi',
      'icon': Icons.sentiment_very_satisfied,
      'color': Colors.yellow
    },
    {
      'id': 18,
      'name': 'Dram',
      'icon': Icons.theater_comedy,
      'color': Colors.blue
    },
    {
      'id': 878,
      'name': 'Bilim Kurgu',
      'icon': Icons.science,
      'color': Colors.purple
    },
    {
      'id': 10749,
      'name': 'Romantik',
      'icon': Icons.favorite,
      'color': Colors.pink
    },
    {
      'id': 27,
      'name': 'Korku',
      'icon': Icons.visibility_off,
      'color': Colors.black
    },
    {
      'id': 53,
      'name': 'Gerilim',
      'icon': Icons.warning,
      'color': Colors.orange
    },
    {
      'id': 16,
      'name': 'Animasyon',
      'icon': Icons.animation,
      'color': Colors.green
    },
    {'id': 80, 'name': 'Suç', 'icon': Icons.gavel, 'color': Colors.brown},
    {
      'id': 99,
      'name': 'Belgesel',
      'icon': Icons.language,
      'color': Colors.teal
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 0, 28), // Senin tema rengi
      appBar: AppBar(
        title: const Text(
          "Film Türleri",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: genres.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final genre = genres[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        GenreBrowseMovies(genreId: genre['id']),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [
                      genre['color'].withOpacity(0.8),
                      genre['color'].withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: genre['color'].withOpacity(0.5),
                      blurRadius: 8,
                      offset: const Offset(2, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        genre['icon'],
                        size: 40,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        genre['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
