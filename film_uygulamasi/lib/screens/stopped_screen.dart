import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'movie_detail_screen.dart'; // Film detay ekranını içe aktar
import 'package:intl/intl.dart'; // Tarih formatı için ekleme

class DroppedMoviesScreen extends StatelessWidget {
  const DroppedMoviesScreen({super.key});

  // Firestore'dan 'library' koleksiyonunu çekiyoruz
  Future<List<Map<String, dynamic>>> _fetchDroppedMoviesScreen() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Kullanıcı oturum açmamış.');
      }

      // 'library' koleksiyonundan kategoriye göre filtreleme yapıyoruz
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library') // 'library' koleksiyonu
          .where('category',
              isEqualTo: "Yarıda Bıraktıklarım") // Kategoriyi filtrele
          .get();

      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      debugPrint('Hata: $e');
      return [];
    }
  }

  // Tarih formatlama işlevi
  String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yyyy').format(parsedDate);
    } catch (e) {
      return 'Geçersiz tarih';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yarıda Bıraktıklarım',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.red.shade800, // Ana mavi tonu
        elevation: 5.0,
        centerTitle: false, // Başlık ortalanmış
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDroppedMoviesScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Hata oluştu. Lütfen tekrar deneyin.'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('İzlediğiniz film bulunamadı.'));
          }

          final movies = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio:
                      0.7, // Kart boyutunu daha estetik hale getirdim
                  crossAxisSpacing: 16.0, // Kartlar arası mesafeyi artırdım
                  mainAxisSpacing: 16.0,
                ),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  final movie = movies[index];
                  return GestureDetector(
                    onTap: () {
                      final movieId = movie['movieId'] ?? 0;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MovieDetailScreen(
                            movieId: movieId,
                            title: movie['title'] ?? 'Bilinmeyen Başlık',
                            releaseDate:
                                movie['releaseDate'] ?? 'Bilinmeyen Tarih',
                            imageUrl: movie['imageUrl'] ?? '',
                            description:
                                movie['description'] ?? 'Açıklama bulunmuyor',
                            duration: movie['duration'] ?? 'Bilinmiyor',
                            yearStarted:
                                movie['releaseDate']?.substring(0, 4) ??
                                    'Bilinmiyor',
                            episodes: movie['episodes']?.toString() ?? 'Yok',
                            mediaType: movie['media_type'] ?? 'movie',
                            genre: movie['genre_ids'] ?? [],
                            images: [movie['imageUrl'] ?? ''],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      color: const Color.fromARGB(255, 19, 0, 28),
                      shadowColor: Colors.black,
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: movie['imageUrl'] != null
                                ? Image.network(
                                    movie['imageUrl'],
                                    width: double.infinity,
                                    height: 180, // Kartın yüksekliği
                                    fit: BoxFit
                                        .cover, // Resmi düzgün şekilde yerleştir
                                  )
                                : const Icon(
                                    Icons.movie,
                                    size: 60,
                                    color: Colors.red,
                                  ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movie['title'] ?? 'Bilinmeyen Film',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red.shade900,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      movie['releaseDate'] != null
                                          ? _formatDate(movie['releaseDate'])
                                          : 'Tarih yok',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
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
          );
        },
      ),
      backgroundColor:
          const Color.fromARGB(255, 19, 0, 28), // Arka plan rengini değiştir
    );
  }
}
