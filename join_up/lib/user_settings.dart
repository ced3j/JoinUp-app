import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase için eklendi
import 'firebase_options.dart';// Firebase için eklendi


void main() async { // Firebase için eklendi (async)

  WidgetsFlutterBinding.ensureInitialized(); // Firebase için eklendi

  await Firebase.initializeApp( // Firebase için eklendi
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UserSettings());
}

class UserSettings extends StatelessWidget {
  const UserSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle style = TextButton.styleFrom(
      foregroundColor: Theme.of(context).colorScheme.onPrimary,
    );
    return Scaffold(
      
      appBar: AppBar(
        actions: <Widget>[
          TextButton(style: style, onPressed: () {}, child: const Text('Action 1')),
          TextButton(style: style, onPressed: () {}, child: const Text('Action 2')),
        ],
      ),
    );
  }
}
