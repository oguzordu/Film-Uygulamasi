import 'package:flutter/material.dart';
import 'package:film_uygulamasi/services/api_service.dart';
import 'package:film_uygulamasi/screens/movie_detail_screen.dart';
import 'package:shimmer/shimmer.dart';

class GenreBrowseMovies extends StatefulWidget {
  final int genreId;

  const GenreBrowseMovies({super.key, required this.genreId});

  @override
  GenreBrowseMoviesState createState() => GenreBrowseMoviesState();
}

class GenreBrowseMoviesState extends State<GenreBrowseMovies> {
  List genreMovies = [];
  bool isMoviesLoading = true;

  final Map<int, String> genreNames = {
    28: 'Aksiyon',
    35: 'Komedi',
    18: 'Dram',
    878: 'Bilim Kurgu',
    10749: 'Romantik',
    27: 'Korku',
    53: 'Gerilim',
    16: 'Animasyon',
    80: 'Suç',
    99: 'Belgesel',
    10402: 'Müzik',
    10751: 'Aile',
  };

  @override
  void initState() {
    super.initState();
    fetchGenreMovies();
  }

  Future<void> fetchGenreMovies() async {
    try {
      final movies = await ApiService().fetchMoviesByGenre(widget.genreId);

      if (mounted) {
        setState(() {
          genreMovies = movies;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isMoviesLoading = false;
        });
      }
    }
  }

  void _openMovieDetails(int index, List movies) {
    final movie = movies[index];

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MovieDetailScreen(
          movieId: movie['id'],
          title: movie['title'] ?? 'Unknown Title',
          releaseDate: movie['release_date'] ?? 'Unknown',
          imageUrl: 'https://image.tmdb.org/t/p/w500${movie['poster_path']}',
          description: movie['overview'] ?? 'Description not available',
          duration: 'Not Available',
          yearStarted: movie['release_date']?.substring(0, 4) ?? 'Unknown',
          episodes: 'Not Applicable',
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
        title: Text(
          genreNames[widget.genreId] ?? 'Filmler',
          style:
              const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Geri tuşunun rengini beyaz yapıyoruz
        ),
      ),
      body: isMoviesLoading
          ? _buildShimmerEffect() // Yüklenirken shimmer efekti
          : Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12.0,
                  mainAxisSpacing: 12.0,
                  childAspectRatio: 0.68,
                ),
                itemCount: genreMovies.length,
                itemBuilder: (context, index) {
                  final movie = genreMovies[index];

                  return GestureDetector(
                    onTap: () => _openMovieDetails(index, genreMovies),
                    child: Stack(
                      children: [
                        // Kartın arka planı ve film posteri
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14.0),
                          child: Image.network(
                            movie['poster_path'] != null
                                ? 'https://image.tmdb.org/t/p/w500${movie['poster_path']}'
                                : 'https://via.placeholder.com/500x750?text=No+Image',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        // Yarı saydam blur efektli film ismi
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8.0, horizontal: 12.0),
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(14.0),
                              ),
                              color: Colors.black,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black,
                                  blurRadius: 8.0,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Text(
                              movie['title'] ?? 'Bilinmeyen',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  // Shimmer efekti (Yüklenirken daha şık bir bekleme animasyonu)
  Widget _buildShimmerEffect() {
    return GridView.builder(
      padding: const EdgeInsets.all(12.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.0,
        mainAxisSpacing: 12.0,
        childAspectRatio: 0.68,
      ),
      itemCount: 6, // Geçici 6 adet shimmer kart gösterilecek
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[800]!,
          highlightColor: Colors.grey[600]!,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(14.0),
            ),
          ),
        );
      },
    );
  }
}
