import 'package:flutter/material.dart';
import 'package:join_up/account_screen.dart';
import 'package:join_up/login_screen.dart';
import 'package:join_up/my_events_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';



final String uid = FirebaseAuth.instance.currentUser!.uid;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(  
      appBar: AppBar(
        title: const Text("Profil"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Column(
          children: [
            // Profil resmi
            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.jpg"), // veya NetworkImage
            ),
            const SizedBox(height: 16),
            // Ad & Email
            const Text(
              "Ad Soyad",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "email@example.com",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            // Hamburger menü gibi gözüken liste
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Hesap Bilgileri"),
                    onTap: () {
                      Navigator.push(
                          context,
                          
                          MaterialPageRoute(
                             builder: (context) => AccountScreen(),
                            ),// Hesap bilgileri sayfası
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.favorite),
                    title: const Text("Etkinliklerim"),
                    onTap: () {
                        Navigator.push(
                          context,
                          
                          MaterialPageRoute(
                             builder: (context) => MyEventsPage(userId: FirebaseAuth.instance.currentUser!.uid),
                            ),
                          );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.room_service_sharp),
                    title: const Text("İstekler"),
                    onTap: () {
                      // Yardım sayfası
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text("Çıkış Yap"),
                    onTap: () {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                          (Route<dynamic> route) => false, // Çıkış işlemi
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
