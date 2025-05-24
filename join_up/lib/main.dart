import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;

  runApp(MainApp(keepLoggedIn: keepLoggedIn));
}

class MainApp extends StatelessWidget {
  final bool keepLoggedIn;

  const MainApp({super.key, required this.keepLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: keepLoggedIn ? const HomePage() : const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
