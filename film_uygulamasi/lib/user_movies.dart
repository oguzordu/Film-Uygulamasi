// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // For user authentication

class UserMoviesScreen extends StatefulWidget {
  const UserMoviesScreen({super.key});

  @override
  UserMoviesScreenState createState() => UserMoviesScreenState();
}

class UserMoviesScreenState extends State<UserMoviesScreen> {
  List userMovies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserMovies();
  }

  Future<void> fetchUserMovies() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('library') // 'movies' yerine 'library' kullanılacak
          .orderBy('timestamp', descending: true)
          .get();

      if (!mounted) return;
      setState(() {
        userMovies = querySnapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'title': doc['title'],
            'releaseDate': doc['releaseDate'],
            'imageUrl': doc['imageUrl'],
            'description': doc['description'],
            'category': doc['category'],
            'rating': doc['rating'],
          };
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch movies: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 0, 28),
      appBar: AppBar(
        title: const Text('My Movies'),
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: userMovies.length,
              itemBuilder: (context, index) {
                final movie = userMovies[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  color: const Color(0xFF2A2A2A),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(8),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie['imageUrl'],
                        width: 80,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      movie['title'],
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      '${movie['releaseDate']} | ${movie['category']}',
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteMovie(movie);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _deleteMovie(Map<String, dynamic> movie) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not logged in");
      }

      final movieId = movie['id'];
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('movies')
          .doc(movieId)
          .delete();

      setState(() {
        userMovies.removeWhere((m) => m['id'] == movieId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Movie deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete movie: $e')),
      );
    }
  }
}
