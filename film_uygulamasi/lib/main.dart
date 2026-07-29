import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase import
import 'navigation_bar_screen.dart'; // NavigationBarScreen import

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(); // Initialize Firebase

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Film Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const NavigationBarScreen(), // NavigationBarScreen remains as home
    );
  }
}
