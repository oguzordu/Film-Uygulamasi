import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_register_screen.dart';
import 'watched_screen.dart';
import 'watching_screen.dart';
import 'stopped_screen.dart';
import 'watchlist_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  final List<Map<String, dynamic>> statuses = [
    {
      "title": "İzlediklerim",
      "color": Colors.blue,
      "icon": Icons.check_circle_outline,
      "screen": const CompletedMoviesScreen(),
    },
    {
      "title": "İzlemeye Devam Ettiklerim",
      "color": Colors.green,
      "icon": Icons.play_circle_fill,
      "screen": const InProgressMoviesScreen(),
    },
    {
      "title": "Yarıda Bıraktıklarım",
      "color": Colors.red,
      "icon": Icons.cancel_outlined,
      "screen": const DroppedMoviesScreen(),
    },
    {
      "title": "İzlemek İstediklerim",
      "color": Colors.yellow.shade700,
      "icon": Icons.bookmark_border,
      "screen": const WatchlistMoviesScreen(),
    },
  ];

  bool _isLoggedIn = false; // To track if the user is logged in

  @override
  void initState() {
    super.initState();
    _checkIfUserIsLoggedIn();
  }

  // Check if the user is logged in
  Future<void> _checkIfUserIsLoggedIn() async {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      _isLoggedIn = user != null; // If the user is not null, they are logged in
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Kitaplığım',
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 19, 0, 28),
        elevation: 4.0,
        titleSpacing: 16.0, // Title left alignment
      ),
      body: _isLoggedIn
          ? ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              itemCount: statuses.length,
              itemBuilder: (context, index) {
                final status = statuses[index];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => status["screen"]),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: status["color"].withOpacity(0.5),
                          blurRadius: 8,
                          offset: const Offset(2, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Icon(
                        status["icon"],
                        color: status["color"],
                        size: 32,
                      ),
                      title: Text(
                        status["title"],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                );
              },
            )
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      color: Colors.white,
                      size: 60,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Kütüphaneyi kullanmak için giriş yapmanız lazım.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const LoginRegisterScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue, // Button color
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 30.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text(
                        'Giriş Yap',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
