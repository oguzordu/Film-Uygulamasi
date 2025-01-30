// ignore_for_file: avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'login_register_screen.dart'; // Giriş ekranı
import 'home_screen.dart'; // Ana sayfa
import 'package:film_uygulamasi/navigation_bar_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _profileImageUrl;
  String? _username;

  List<String> characterImagePaths = [
    'assets/images/spider_man.jpg',
    'assets/images/miles_morales.jpg',
    'assets/images/simba.jpg',
    'assets/images/edward.jpg',
    'assets/images/dora.jpg',
    'assets/images/darth_vader.jpg',
    'assets/images/alien.jpg',
    'assets/images/11.jpg',
    'assets/images/stitch.jpg',
    'assets/images/godzilla.jpg',
    // Diğer karakter fotoğraflarını buraya ekleyin
  ];

  int watchedMovies = 0;
  int inProgressMovies = 0;
  int unfinishedMovies = 0;
  int watchlistMovies = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Profil fotoğrafını ve kullanıcı adını Firestore'a güncelleme

  // Film karakteri fotoğrafı seçmek için Popup
  Future<void> _selectCharacterImage() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Bir Fotoğraf Seçin'),
          content: SizedBox(
            width: double.maxFinite,
            height: 250, // Increased the height for more space
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 4 sütun
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: characterImagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    _updateProfileImage(characterImagePaths[index]);
                    Navigator.pop(context); // Popup'ı kapat
                  },
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage(characterImagePaths[index]),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // Kullanıcı adını güncellemek için metot ekleme

  // Profil fotoğrafını Firestore'a güncelleme
  Future<void> _updateProfileImage(String imagePath) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profileImageUrl': imagePath,
      });

      if (mounted) {
        setState(() {
          _profileImageUrl = imagePath;
        });
      }

      print("Image updated successfully! Path: $imagePath");
    } catch (e) {
      print('Error updating image: $e');
    }
  }

  // Kullanıcı verilerini ve film kategorilerini Firestore'dan yüklemek
  Future<void> _loadUserData() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        await _loadMovieCategories(user.uid);

        if (mounted) {
          setState(() {
            _profileImageUrl = userData['profileImageUrl'] ?? '';
            _username = userData['username'] ?? 'Kullanıcı Adı';
          });
        }
      } catch (e) {
        print('Error loading user data: $e');
      }
    }
  }

  // Film kategorilerini yükleyip, sayıları güncellemek
  Future<void> _loadMovieCategories(String userId) async {
    try {
      final userMoviesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('library')
          .get();

      int watched = 0;
      int inProgress = 0;
      int unfinished = 0;
      int watchlist = 0;

      for (var movieDoc in userMoviesSnapshot.docs) {
        final movieCategory = movieDoc['category'];

        switch (movieCategory) {
          case 'İzlediklerim':
            watched++;
            break;
          case 'İzlemeye Devam Ettiklerim':
            inProgress++;
            break;
          case 'Yarıda Bıraktıklarım':
            unfinished++;
            break;
          case 'İzlemek İstediklerim':
            watchlist++;
            break;
          default:
            break;
        }
      }

      setState(() {
        watchedMovies = watched;
        inProgressMovies = inProgress;
        unfinishedMovies = unfinished;
        watchlistMovies = watchlist;
      });
    } catch (e) {
      print('Error loading movie categories: $e');
    }
  }

  // Pie chart verisi
  List<PieChartSectionData> _pieChartSections() {
    return [
      PieChartSectionData(
        value: watchedMovies.toDouble(),
        color: Colors.blue,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: inProgressMovies.toDouble(),
        color: Colors.green,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: unfinishedMovies.toDouble(),
        color: Colors.red,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      PieChartSectionData(
        value: watchlistMovies.toDouble(),
        color: Colors.yellow,
        radius: 40,
        titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    ];
  }

  // Çıkış yapma işlemi için onay dialog'u
  Future<void> _showLogoutDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Çıkış Yapmak İstediğinizden Emin Misiniz?',
            style: TextStyle(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await _auth.signOut();
                // Kullanıcı çıkışı sonrası HomeScreen ve NavigationBarScreen yönlendirmesi
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                  (route) => false, // Tüm geçmişi temizle
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NavigationBarScreen(),
                  ),
                  (route) => false, // Tüm geçmişi temizle
                );
              },
              child: const Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hayır'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;

    if (user == null) {
      return const LoginRegisterScreen();
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 19, 0, 28),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 19, 0, 28),
        title: const Text(
          'Ben',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _showLogoutDialog, // Çıkış yapmadan önce onay al
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Stack(
                  alignment: Alignment.bottomRight, // Sağ üst köşe hizalama
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: _profileImageUrl != null &&
                              _profileImageUrl!.isNotEmpty
                          ? AssetImage(_profileImageUrl!)
                          : const AssetImage(
                                  'assets/images/default_profile_pic.png')
                              as ImageProvider,
                    ),
                    Container(
                      width: 40, // Balonun genişliğini küçülttük
                      height: 40, // Balonun yüksekliğini küçülttük
                      decoration: BoxDecoration(
                        color: Colors.blue, // Balonun rengi
                        shape: BoxShape.circle, // Yuvarlak şekil
                        border: Border.all(
                            color: Colors.white, width: 2), // Beyaz kenarlık
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: _selectCharacterImage,
                        color: Colors.white,
                        iconSize: 18, // İkonun rengi
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Text(
                  _username ?? 'Kullanıcı Adı',
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'Film Kategorileri',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 250,
                  width: 230,
                  child: PieChart(
                    PieChartData(
                      sections: _pieChartSections(),
                      borderData: FlBorderData(show: false),
                      sectionsSpace: 0,
                      centerSpaceRadius: 50,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'İzlediklerim',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          watchedMovies.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'İzlemeye Devam Ettiklerim',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          inProgressMovies.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.red,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Yarıda Bıraktıklarım',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          unfinishedMovies.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          color: Colors.yellow,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'İzlemek İstediklerim',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          watchlistMovies.toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
