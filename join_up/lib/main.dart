import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase için eklendi
import 'firebase_options.dart'; // Firebase için eklendi
import 'splash_screen.dart';

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
    return MaterialApp(home: SplashScreen(), debugShowCheckedModeBanner: false);
  }
}

void showCustomSnackBar(BuildContext context, String message, int type) {
  final backgroundColor =
      (type == 1)
          ? Color.fromARGB(255, 171, 214, 174)
          : Color.fromARGB(255, 237, 96, 78);

  final icon = (type == 1) ? Icons.check_circle : Icons.cancel;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.white),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      duration: Duration(seconds: 3),
    ),
  );
}
