import 'dart:async';
import 'package:flutter/material.dart';
import 'package:film_uygulamasi/screens/movie_detail_screen.dart';
import 'package:film_uygulamasi/services/api_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  Timer? _debounce;

  void searchMovies() async {
    String query = searchController.text;
    if (query.isNotEmpty) {
      try {
        List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(
            await ApiService().searchMovies(query));

        if (!mounted) return;

        if (results.isEmpty) {
          setState(() {
            searchResults = [];
          });
          return;
        }

        results.sort((a, b) => b['popularity'].compareTo(a['popularity']));

        results = results.where((film) {
          return film['media_type'] == 'movie' || film['media_type'] == 'tv';
        }).toList();

        setState(() {
          searchResults = results;
        });
      } catch (e) {
        if (!mounted) return;
        setState(() {
          searchResults = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } else {
      setState(() {
        searchResults = [];
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      searchMovies();
    });
  }

  void _openMovieDetails(int index, List movies) {
    final movie = movies[index];

    String duration = 'Not Available';
    String releaseDate = movie['release_date'] ?? 'Unknown';
    String episodes = 'Not Applicable';

    if (movie['media_type'] == 'tv') {
      duration = 'N/A';
      episodes = movie['number_of_episodes'] != null
          ? '${movie['number_of_episodes']} Episodes'
          : 'N/A';
      releaseDate = movie['first_air_date'] ?? 'Unknown';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieId: movie['id'],
          title: movie['title'] ?? 'Unknown Title',
          releaseDate: releaseDate,
          imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
          description: movie['overview'] ?? 'Description not available',
          duration: duration,
          yearStarted: movie['release_date']?.substring(0, 4) ?? 'Unknown',
          episodes: episodes,
          mediaType: movie['media_type'] ?? 'movie',
          genre: movie['genre_ids'] ?? [],
          images: ['https://image.tmdb.org/t/p/w500${movie['poster_path']}'],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 0, 28),
      appBar: AppBar(
        title: const Text(
          'Search Movies',
          style: TextStyle(color: Colors.white), // Burada beyaz renk ekliyoruz
        ),
        backgroundColor: const Color.fromARGB(255, 19, 0, 28),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Büyüteç ikonu sol tarafta
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                    child: Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                  ),
                  // Arama kutusu
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        hintText: 'Search for movies, series...',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  // Clear simgesi sağda
                  if (searchController.text.isNotEmpty)
                    IconButton(
                      onPressed: () {
                        searchController.clear();
                        FocusScope.of(context).unfocus(); // Klavye kapanır
                      },
                      icon: const Icon(
                        Icons.clear,
                        color: Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'No results found',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: 0.65,
                    ),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final movie = searchResults[index];
                      String title =
                          movie['title'] ?? movie['name'] ?? 'Unknown Title';

                      return GestureDetector(
                        onTap: () => _openMovieDetails(index, searchResults),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: GridTile(
                            footer: GridTileBar(
                              backgroundColor: Colors.black54,
                              title: Text(
                                title,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.network(
                                'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
