import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:join_up/account_screen.dart';
import 'package:join_up/login_screen.dart';
import 'package:join_up/my_events_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF6F2DBD);
const Color accentColor = Color(0xFFFFD600);
const Color backgroundFieldColor = Color(0xFFFEF7FF);
const Color labelTextColor = Color(0xFF0E1116);

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<Map<String, dynamic>?> _getUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundFieldColor,
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null) {
              return const Center(
                child: Text("Kullanıcı bilgileri bulunamadı"),
              );
            }

            final userData = snapshot.data!;
            final fullName = userData["fullName"] ?? "Ad Soyad";
            final email = userData["email"] ?? "email@example.com";

            return Column(
              children: [
                // Üst mor başlık ve geri tuşu
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                      ),
                      child: Stack(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 65),
                              child: Text(
                                "Profil",
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const Positioned(
                            top: 16,
                            left: 8,
                            child: BackButton(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: MediaQuery.of(context).size.width / 2 - 50,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: const AssetImage('assets/profile.jpg'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 70),

                Text(
                  fullName,
                  style: GoogleFonts.montserrat(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: labelTextColor,
                  ),
                ),
                Text(
                  email,
                  style: GoogleFonts.montserrat(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 24),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildProfileTile(
                        icon: Icons.person,
                        title: "Hesap Bilgileri",
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AccountScreen(),
                              ),
                            ),
                      ),
                      _buildProfileTile(
                        icon: Icons.favorite,
                        title: "Etkinliklerim",
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => MyEventsPage(
                                      userId:
                                          FirebaseAuth
                                              .instance
                                              .currentUser!
                                              .uid,
                                    ),
                              ),
                            ),
                      ),
                      _buildProfileTile(
                        icon: Icons.logout,
                        title: "Çıkış Yap",
                        onTap: () async {
                          await FirebaseAuth.instance.signOut();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('keepLoggedIn', false);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: primaryColor),
        title: Text(
          title,
          style: GoogleFonts.montserrat(
            fontWeight: FontWeight.w500,
            color: labelTextColor,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
