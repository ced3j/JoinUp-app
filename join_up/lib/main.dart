import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase için eklendi
import 'firebase_options.dart'; // Firebase için eklendi
import 'splash_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();
  final keepLoggedIn = prefs.getBool('keepLoggedIn') ?? false;
  final currentUser = FirebaseAuth.instance.currentUser;

  runApp(MainApp(keepLoggedIn: keepLoggedIn && currentUser != null));
}

class MainApp extends StatelessWidget {
  final bool keepLoggedIn;

  const MainApp({super.key, required this.keepLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);

  }
}
