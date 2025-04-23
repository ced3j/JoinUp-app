import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase için eklendi
import 'firebase_options.dart'; // Firebase için eklendi
import 'login_screen.dart';

void main() async {
  // Firebase için eklendi (async)

  WidgetsFlutterBinding.ensureInitialized(); // Firebase için eklendi

  await Firebase.initializeApp(
    // Firebase için eklendi
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: LoginPage(), debugShowCheckedModeBanner: false);
  }
}
