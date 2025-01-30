import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ApiService {
  final String apiKey = '52a0f675a43877834e14d5931959f607';
  final String baseUrl = 'https://api.themoviedb.org/3';

  // Method to fetch popular movies (limit to 10 movies)
  Future<List<dynamic>> fetchPopularMovies() async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=1&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'].take(10).toList(); // Limit to 10 movies
    } else {
      throw Exception('Failed to load popular movies');
    }
  }

  // Method to fetch upcoming movies from multiple pages
  Future<List<dynamic>> fetchUpcomingMovies() async {
    final List<dynamic> allUpcomingMovies = [];

    // Get the current date
    final now = DateTime.now();
    final currentDate = DateFormat('yyyy-MM-dd').format(now);

    // Fetch movies from multiple pages until we gather 10 valid results
    int page = 1;
    while (allUpcomingMovies.length < 10) {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/movie/upcoming?api_key=$apiKey&page=$page&language=en-US'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> results = List<dynamic>.from(data['results'] ?? []);

        // Filter out movies that are already released
        final upcomingMovies = results.where((movie) {
          final releaseDate = movie['release_date'];
          if (releaseDate != null) {
            return releaseDate.compareTo(currentDate) >
                0; // Only future releases
          }
          return false; // If there's no release date, filter it out
        }).toList();

        // Add the filtered upcoming movies to the list
        allUpcomingMovies.addAll(upcomingMovies);

        // If we already have 10 movies, break the loop
        if (allUpcomingMovies.length >= 10) {
          break;
        }
      } else {
        throw Exception('Failed to load upcoming movies');
      }

      page++; // Move to the next page
    }

    // Limit the result to 10 movies after gathering data from multiple pages
    return allUpcomingMovies.take(10).toList();
  }

  // Method to fetch popular TV shows
  Future<List<dynamic>> fetchPopularTV() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tv/popular?api_key=$apiKey&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'].take(10).toList(); // Limit to 10 TV shows
    } else {
      throw Exception('Failed to load popular TV shows');
    }
  }

  // Method to fetch movies by genre
  Future<List<dynamic>> fetchMoviesByGenre(int genreId) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/discover/movie?api_key=$apiKey&with_genres=$genreId&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'].take(10).toList(); // Limit to 10 movies
    } else {
      throw Exception('Failed to load movies by genre');
    }
  }

  // Method to search movies
  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/search/multi?api_key=$apiKey&query=$query&language=en-US'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // Safely return the results (ensure it is a List)
      final List<dynamic> results = data['results'] ?? [];
      return List<Map<String, dynamic>>.from(results);
    } else {
      throw Exception('Failed to search movies');
    }
  }
}
