// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase integration
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class MovieDetailScreen extends StatefulWidget {
  final int? movieId;
  final String title;
  final String releaseDate;
  final String imageUrl;
  final String description;
  final String duration;
  final String yearStarted;
  final String episodes;
  final String mediaType;
  final List genre;

  const MovieDetailScreen({
    super.key,
    this.movieId,
    required this.title,
    required this.releaseDate,
    required this.imageUrl,
    required this.description,
    required this.duration,
    required this.yearStarted,
    required this.episodes,
    required this.mediaType,
    required this.genre,
    required List<String> images,
  });

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool isLoading = true;
  List cast = [];
  List similarMovies = [];
  List images = [];
  String runtime = "Not Available";
  String formattedReleaseDate = '';
  double userRating = 0.0;
  TextEditingController reviewController = TextEditingController();
  List reviews = []; // Store reviews from Firestore
  double averageRating = 0.0;

  @override
  void initState() {
    super.initState();
    fetchMovieDetails();
    fetchRatingsAndReviews();
  }

  ImageProvider _getImageProvider(String? profileImageUrl) {
    if (profileImageUrl == null || profileImageUrl.isEmpty) {
      // Eğer URL boşsa, varsayılan resmi kullan
      return const AssetImage('assets/images/default_avatar.jpg');
    }

    // Eğer resim bir yerel dosya yoluysa, AssetImage kullanılır
    return AssetImage(profileImageUrl);
  }

  Future<List<Map<String, dynamic>>> fetchReviews() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movieId.toString())
          .collection('ratings_and_reviews')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Firestore ID'sini ekleyin
          'userId': doc['userId'], // Kullanıcı ID'sini ekleyin
          'username': doc['username'],
          'rating': doc['rating'],
          'review': doc['review'],
          'profileImageUrl': doc['profileImageUrl'],
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movieId.toString())
          .collection('ratings_and_reviews')
          .doc(reviewId) // İncelemenin ID'si ile ilgili belgeyi sil
          .delete();
      _showSuccessSnackbar("İnceleme başarıyla silindi.");
      await fetchRatingsAndReviews(); // İnceleme silindikten sonra güncelleme yap
    } catch (e) {
      _showErrorSnackbar("İnceleme silinirken bir hata oluştu: $e");
    }
  }

  Future<void> fetchRatingsAndReviews() async {
    try {
      final movieRatingsAndReviews = await FirebaseFirestore.instance
          .collection('movies')
          .doc(widget.movieId.toString())
          .collection('ratings_and_reviews')
          .get();

      if (movieRatingsAndReviews.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var doc in movieRatingsAndReviews.docs) {
          totalRating += doc['rating'];

          final username =
              doc['username'] ?? 'Unknown User'; // Varsayılan kullanıcı adı
          final profileImageUrl = doc['profileImageUrl'] ??
              ''; // Firebase'ten alınan profil resminin URL'si

          setState(() {
            reviews.add({
              'review': doc['review'] ?? '', // Eğer review null ise boş string
              'rating': doc['rating'],
              'username': username,
              'profileImageUrl': profileImageUrl, // Fotoğraf URL'si
            });
          });
        }
        averageRating = totalRating / movieRatingsAndReviews.docs.length;
      }
    } catch (e) {
      _showErrorSnackbar('Error loading ratings and reviews: $e');
    }
  }

  Future<void> saveRatingAndReview() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String username = 'Unknown User';
      String profileImageUrl = 'assets/images/default_profile_pic.jpg';

      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (userDoc.exists) {
          username = userDoc['username'] ?? username;
          profileImageUrl = userDoc['profileImageUrl'] ?? profileImageUrl;
        }
      } catch (e) {
        _showErrorSnackbar('Error fetching username or profile picture: $e');
      }

      try {
        // Save the rating and review to Firestore
        await FirebaseFirestore.instance
            .collection('movies')
            .doc(widget.movieId.toString())
            .collection('ratings_and_reviews')
            .add({
          'userId': user.uid,
          'username': username,
          'profileImageUrl': profileImageUrl,
          'rating': userRating, // The rating chosen by the user
          'review': reviewController.text, // The review entered by the user
          'timestamp': FieldValue.serverTimestamp(), // Timestamp for the review
        });

        // Re-fetch reviews and ratings
        await fetchRatingsAndReviews(); // Refresh the reviews section
      } catch (e) {
        _showErrorSnackbar('Error saving rating and review: $e');
      }
    }
  }

  Future<void> fetchMovieDetails() async {
    const apiKey = '52a0f675a43877834e14d5931959f607';
    final movieDetailsUrl = Uri.parse(
        'https://api.themoviedb.org/3/movie/${widget.movieId}?api_key=$apiKey&language=en-US');
    final castUrl = Uri.parse(
        'https://api.themoviedb.org/3/movie/${widget.movieId}/credits?api_key=$apiKey&language=en-US');
    final imagesUrl = Uri.parse(
        'https://api.themoviedb.org/3/movie/${widget.movieId}/images?api_key=$apiKey');
    final similarMoviesUrl = Uri.parse(
        'https://api.themoviedb.org/3/movie/${widget.movieId}/similar?api_key=$apiKey&language=en-US&page=1');
    try {
      final movieResponse = await http.get(movieDetailsUrl);
      final castResponse = await http.get(castUrl);
      final imagesResponse = await http.get(imagesUrl);
      final similarMoviesResponse = await http.get(similarMoviesUrl);
      if (movieResponse.statusCode == 200 &&
          castResponse.statusCode == 200 &&
          imagesResponse.statusCode == 200 &&
          similarMoviesResponse.statusCode == 200) {
        final movieData = json.decode(movieResponse.body);
        final castData = json.decode(castResponse.body);
        final imagesData = json.decode(imagesResponse.body);
        final similarMoviesData = json.decode(similarMoviesResponse.body);
        DateTime releaseDateTime = DateTime.parse(movieData['release_date']);
        formattedReleaseDate = DateFormat('dd/MM/yyyy').format(releaseDateTime);
        if (mounted) {
          setState(() {
            runtime = movieData['runtime'] != null
                ? "${movieData['runtime']} dakika"
                : "Not Available";
            cast = castData['cast'] ?? [];
            similarMovies = similarMoviesData['results'] ?? [];
            images = imagesData['backdrops'] ?? [];
            isLoading = false;
          });
        }
      } else {
        _showErrorSnackbar('Film detayları yüklenemedi.');
      }
    } catch (e) {
      _showErrorSnackbar('Bir hata oluştu: $e');
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _saveMovieToLibrary(String category) {
    final user = FirebaseAuth.instance.currentUser; // Get current user
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users') // Access users collection
          .doc(user.uid) // Access the current user's document
          .collection('library') // Access their library subcollection
          .add({
        'title': widget.title,
        'releaseDate': widget.releaseDate,
        'imageUrl': widget.imageUrl,
        'description': widget.description,
        'category': category,
        'timestamp': FieldValue.serverTimestamp(),
        'rating': userRating,
        'movieId': widget.movieId,
        'genre': widget.genre,
        'media_type': widget.mediaType,
        'duration': runtime,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$category kategorisine eklendi!')),
        );
      }).catchError((error) {
        _showErrorSnackbar('Film kaydedilemedi: $error');
      });
    } else {
      _showErrorSnackbar('Kullanıcı giriş yapmamış!');
    }
  }

  void _showCategoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Filmi Kaydet"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("İzlediklerim"),
                onTap: () {
                  _saveMovieToLibrary("İzlediklerim");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("İzlemeye Devam Ettiklerim"),
                onTap: () {
                  _saveMovieToLibrary("İzlemeye Devam Ettiklerim");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Yarıda Bıraktıklarım"),
                onTap: () {
                  _saveMovieToLibrary("Yarıda Bıraktıklarım");
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("İzlemek İstediklerim"),
                onTap: () {
                  _saveMovieToLibrary("İzlemek İstediklerim");
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 0, 28),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        title: Text(
          widget.title,
          style:
              const TextStyle(color: Colors.white), // Başlık yazısını beyaz yap
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Geri gitme butonunu beyaz yap
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Poster
                      AspectRatio(
                        aspectRatio: 2 / 3,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16), // Movie Title and Details
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ), // Average Rating Display
                            Padding(
                              padding: const EdgeInsets.all(3.0),
                              child: Row(
                                children: [
                                  Text(
                                    'Average Rating: ${averageRating.toStringAsFixed(1)}',
                                    style: const TextStyle(
                                        fontSize: 20, color: Colors.white),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.yellow,
                                  ),
                                ],
                              ),
                            ),
                            // Rating and Review Section
                            const SizedBox(height: 8),
                            Text(
                              '$formattedReleaseDate | $runtime',
                              style: TextStyle(color: Colors.grey[300]),
                            ),
                            const SizedBox(height: 16),

                            // Film İşaretleri (Oylama, Kaydetme, Paylaş)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionIcon(
                                  icon: Icons.add,
                                  label: "Ekle",
                                  onTap: _showCategoryDialog,
                                ),
                                _buildActionIcon(
                                  icon: Icons.star,
                                  label: "Oy Ver",
                                  onTap: () => _showRatingDialog(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            Text(
                              widget.description.isNotEmpty == true
                                  ? widget.description
                                  : "Description not available.",
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 16),
                            // Genres
                            Wrap(
                              spacing: 8,
                              children: widget.genre.map((genre) {
                                if (genre is String) {
                                  return Chip(
                                    label: Text(genre),
                                    backgroundColor: Colors.red,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                  );
                                } else if (genre is Map &&
                                    genre.containsKey('name')) {
                                  return Chip(
                                    label:
                                        Text(genre['name'] ?? "Unknown Genre"),
                                    backgroundColor: Colors.red,
                                    labelStyle:
                                        const TextStyle(color: Colors.white),
                                  );
                                }
                                return const SizedBox();
                              }).toList(),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Reviews Section
                      _buildSectionTitle("İncelemeler"),
                      SizedBox(
                        height: 200,
                        child: FutureBuilder(
                            future:
                                fetchReviews(), // Method to fetch reviews from Firestore
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              if (snapshot.hasError) {
                                return Center(
                                    child: Text("Error: ${snapshot.error}"));
                              }

                              final reviews = snapshot.data ?? [];

                              if (reviews.isEmpty) {
                                return const Center(
                                    child: Text("Henüz inceleme yapılmamış."));
                              }

                              return ListView.builder(
                                itemCount: reviews.length,
                                itemBuilder: (context, index) {
                                  final review = reviews[index];
                                  final profileImageUrl = review[
                                          'profileImageUrl'] ??
                                      ''; // Firebase'ten alınan profil resminin URL'si

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 16),
                                    child: Card(
                                      color: Colors.grey[800],
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Kullanıcının profil resmini göster
                                                CircleAvatar(
                                                  radius: 20,
                                                  backgroundImage:
                                                      _getImageProvider(
                                                          profileImageUrl),
                                                  backgroundColor: Colors.grey,
                                                  child: profileImageUrl.isEmpty
                                                      ? const Text('U',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white))
                                                      : null, // Profil resmi varsa, harf göstermeyelim
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  review['username'] ??
                                                      'Unknown User',
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16),
                                                ),
                                                const Spacer(),
                                                Text(
                                                  "${review['rating']}/5",
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                                // Çöp kutusu yalnızca kendi incelemesinde görünsün
                                                if (review['userId'] ==
                                                    FirebaseAuth.instance
                                                        .currentUser?.uid)
                                                  IconButton(
                                                    icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white),
                                                    onPressed: () {
                                                      // İncelemeyi silme işlemi
                                                      deleteReview(
                                                          review['id']);
                                                    },
                                                  ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              review['review'] ?? '',
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                      ),

                      const SizedBox(height: 50),
// Film Fotoğrafları (Backdrops) Bölümü
                      _buildSectionTitle("Film Fotoğrafları"),
                      SizedBox(
                        height: 200,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: images.length,
                          itemBuilder: (context, index) {
                            final imagePath = images[index]['file_path'];
                            final imageUrl = imagePath != null
                                ? 'https://image.tmdb.org/t/p/w500$imagePath'
                                : null;

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: imageUrl != null
                                    ? Image.network(
                                        imageUrl,
                                        height: 160,
                                        width: 250,
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.image, size: 80),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20), // Similar Movies Section

                      _buildSectionTitle("Oyuncular"),
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length,
                          itemBuilder: (context, index) {
                            final actor = cast[index];
                            final actorName = actor['name'] ?? 'Unknown';
                            final actorImage = actor['profile_path'] != null
                                ? 'https://image.tmdb.org/t/p/w500${actor['profile_path']}'
                                : null;
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Column(
                                children: [
                                  actorImage != null
                                      ? CircleAvatar(
                                          radius: 40,
                                          backgroundImage:
                                              NetworkImage(actorImage),
                                        )
                                      : const CircleAvatar(
                                          radius: 40,
                                          backgroundColor: Colors.grey,
                                          child: Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ),
                                  const SizedBox(height: 8),
                                  Text(
                                    actorName,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16), // Similar Movies Section
                      _buildSectionTitle("Benzer Filmler"),
                      SizedBox(
                        height: 250, // Container içine yüksekliği ayarladık
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: List.generate(
                              similarMovies.length,
                              (index) {
                                final similarMovie = similarMovies[index];
                                final movieTitle =
                                    similarMovie['title'] ?? 'Unknown';
                                final moviePoster = similarMovie[
                                            'poster_path'] !=
                                        null
                                    ? 'https://image.tmdb.org/t/p/w500${similarMovie['poster_path']}'
                                    : null;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      moviePoster != null
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              child: Image.network(
                                                moviePoster,
                                                height: 160,
                                                width:
                                                    100, // Poster genişliği sabitlendi
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : const Icon(Icons.movie, size: 80),
                                      const SizedBox(height: 8),
                                      // Film ismi uzun ise alt satıra kayacak
                                      SizedBox(
                                        width:
                                            100, // Posterle aynı genişlikte olacak şekilde sınırladık
                                        child: Text(
                                          movieTitle,
                                          maxLines:
                                              2, // İki satıra kadar sığdır
                                          overflow: TextOverflow
                                              .ellipsis, // Fazla uzarsa '...' ile kesilecek
                                          style: const TextStyle(
                                              color: Colors.white),
                                          textAlign: TextAlign
                                              .center, // Başlık ortalanacak
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActionIcon(
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.red,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Filmi Oyla"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Yıldızlı Oylama Alanı
              RatingBar.builder(
                initialRating: userRating,
                minRating: 1,
                maxRating: 5,
                direction: Axis.horizontal,
                allowHalfRating: false,
                itemCount: 5,
                itemSize: 40.0,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  setState(() {
                    userRating = rating;
                  });
                },
              ),
              const SizedBox(height: 16),
              // Yorum Alanı
              TextField(
                controller: reviewController,
                decoration: const InputDecoration(
                  hintText: 'Yorum yazmak isteğe bağlıdır...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Pop-up'ı kapat
              child: const Text("İptal"),
            ),
            ElevatedButton(
              onPressed: () {
                saveRatingAndReview(); // Puan ve yorumu kaydet
                Navigator.pop(context); // Pop-up'ı kapat
              },
              child: const Text("Gönder"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  // Error Snackbar
  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green, // Başarı mesajı için yeşil arka plan
      ),
    );
  }
}
