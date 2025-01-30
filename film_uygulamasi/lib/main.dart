import 'package:flutter/material.dart';
import 'package:logger/logger.dart'; // Logger import
import 'package:firebase_core/firebase_core.dart'; // Firebase import
import 'navigation_bar_screen.dart'; // NavigationBarScreen import

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Ensure Flutter binding is initialized
  await Firebase.initializeApp(); // Initialize Firebase

  var logger = Logger();
  // Log the API key directly (if necessary, consider more secure logging practices)
  logger.d('API Key: 52a0f675a43877834e14d5931959f607');

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
