import 'dart:async';
import 'package:flutter/material.dart';
import 'package:film_uygulamasi/screens/movie_detail_screen.dart';
import 'package:film_uygulamasi/services/api_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  List popularMovies = [];
  List upcomingMovies = [];
  bool isMoviesLoading = true;
  int currentPage = 0;
  bool _isUserInteracting = false;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> fetchMovies() async {
    try {
      final apiService = ApiService();
      final popularMoviesResponse = await apiService.fetchPopularMovies();
      final upcomingMoviesResponse = await apiService.fetchUpcomingMovies();

      if (mounted) {
        setState(() {
          popularMovies = popularMoviesResponse.take(10).toList();
          upcomingMovies =
              upcomingMoviesResponse.take(10).toList(); // Upcoming movies
          isMoviesLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      debugPrint("Error fetching movies: $e");
    }
  }

// Popüler filmler için tıklama işleyicisi
  void _openPopularMovieDetails(int index) {
    final movie = popularMovies[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieId: movie['id'],
          title: movie['title'] ?? 'Unknown Title',
          releaseDate: movie['release_date'] ?? 'Unknown',
          imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
          description: movie['overview'] ?? 'Description not available',
          duration: movie['runtime']?.toString() ?? 'N/A',
          yearStarted:
              movie['release_date']?.substring(0, 4) ?? 'Not Available',
          episodes: movie['episodes']?.toString() ?? 'N/A',
          mediaType: movie['media_type'] ?? 'movie',
          genre: movie['genre_ids'] ?? [],
          images: ['https://image.tmdb.org/t/p/w500${movie['poster_path']}'],
        ),
        // Film detay sayfası
      ),
    );
  }

// Yakında çıkacak filmler için tıklama işleyicisi
  void _openUpcomingMovieDetails(int index) {
    final movie = upcomingMovies[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieId: movie['id'],
          title: movie['title'] ?? 'Unknown Title',
          releaseDate: movie['release_date'] ?? 'Unknown',
          imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
          description: movie['overview'] ?? 'Description not available',
          duration: movie['runtime']?.toString() ?? 'N/A',
          yearStarted:
              movie['release_date']?.substring(0, 4) ?? 'Not Available',
          episodes: movie['episodes']?.toString() ?? 'N/A',
          mediaType: movie['media_type'] ?? 'movie',
          genre: movie['genre_ids'] ?? [],
          images: ['https://image.tmdb.org/t/p/w500${movie['poster_path']}'],
        ), // Film detay sayfası
      ),
    );
  }

  void _startTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_isUserInteracting && popularMovies.isNotEmpty) {
        int nextPage = (currentPage + 1) % popularMovies.length;

        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );

        setState(() {
          currentPage = nextPage;
        });
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isUserInteracting = true;
    });
  }

  void _resumeTimer() {
    setState(() {
      _isUserInteracting = false;
    });
    _startTimer();
  }

  void _goToMovie(int index) {
    _pauseTimer();
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
    );
    setState(() {
      currentPage = index;
    });
    _resumeTimer();
  }

  void _openMovieDetails(int index) {
    _pauseTimer();
    final movie = popularMovies[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieId: movie['id'],
          title: movie['title'] ?? 'Unknown Title',
          releaseDate: movie['release_date'] ?? 'Unknown',
          imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
          description: movie['overview'] ?? 'Description not available',
          duration: movie['runtime']?.toString() ?? 'N/A',
          yearStarted:
              movie['release_date']?.substring(0, 4) ?? 'Not Available',
          episodes: movie['episodes']?.toString() ?? 'N/A',
          mediaType: movie['media_type'] ?? 'movie',
          genre: movie['genre_ids'] ?? [],
          images: ['https://image.tmdb.org/t/p/w500${movie['poster_path']}'],
        ),
      ),
    ).then((_) {
      _resumeTimer();
    });
  }

  Widget _buildMovieSlider() {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.55,
          child: GestureDetector(
            onPanDown: (_) => _pauseTimer(),
            onPanEnd: (_) => _resumeTimer(),
            child: PageView.builder(
              controller: _pageController,
              itemCount: popularMovies.length,
              onPageChanged: (index) {
                setState(() {
                  currentPage = index;
                });
              },
              itemBuilder: (context, index) {
                final movie = popularMovies[index];
                bool isActive = index == currentPage;

                return GestureDetector(
                  onTap: () => _openMovieDetails(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    margin: EdgeInsets.symmetric(
                        vertical: isActive ? 0 : 20, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                              colors: [Colors.black, Colors.transparent],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                movie['title'] ?? 'Başlık Yok',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 5),
                              Text(
                                movie['release_date']?.substring(0, 4) ??
                                    'Tarih Yok',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(popularMovies.length, (index) {
            return GestureDetector(
              onTap: () => _goToMovie(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentPage ? 14 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == currentPage ? Colors.white : Colors.grey,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // Popüler filmleri listeleyen widget
  Widget _buildPopularMovies() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Popüler Filmler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180, // Adjust height for horizontal scrolling
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularMovies.length,
              itemBuilder: (context, index) {
                final movie = popularMovies[index];
                return GestureDetector(
                  onTap: () =>
                      _openPopularMovieDetails(index), // Farklı onTap işlemi
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
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

  // Yakında çıkacak filmleri listeleyen widget
  Widget _buildUpcomingMovies() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Yakında Çıkacak Filmler',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 180, // Adjust height for horizontal scrolling
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: upcomingMovies.length,
              itemBuilder: (context, index) {
                final movie = upcomingMovies[index];
                return GestureDetector(
                  onTap: () =>
                      _openUpcomingMovieDetails(index), // Farklı onTap işlemi
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
                        width: 120,
                        height: 180,
                        fit: BoxFit.cover,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            _buildMovieSlider(),
            _buildUpcomingMovies(),
            _buildPopularMovies(),
            const SizedBox(height: 75),
            // Added Upcoming Movies section
          ],
        ),
      ),
    );
  }
}
