import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // ✅ Status bar kontrolü için
import 'package:google_fonts/google_fonts.dart';
import 'package:join_up/account_screen.dart';
import 'package:join_up/login_screen.dart';
import 'package:join_up/my_events_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Color primaryColor = Color(0xFF6F2DBD);
const Color accentColor = Color(0xFFFFD600);
const Color backgroundFieldColor = Color(0xFFFEF7FF);
const Color labelTextColor = Color(0xFF0E1116);

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _profileImageUrl;
  String _fullName = "Yükleniyor...";
  String _email = "Yükleniyor...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndProfileImage();
  }

  Future<void> _loadUserDataAndProfileImage() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _isLoading = false;
        _fullName = "Misafir Kullanıcı";
        _email = "";
        _profileImageUrl = null;
      });
      return;
    }

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final userData = doc.data()!;
        setState(() {
          _fullName = userData["fullName"] ?? "Ad Soyad";
          _email =
              FirebaseAuth.instance.currentUser?.email ?? "email@example.com";
          _profileImageUrl = userData["profileImage"];
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _fullName = "Kullanıcı Yok";
          _email = "bilgi@yok.com";
          _profileImageUrl = null;
        });
      }
    } catch (e) {
      print("Kullanıcı bilgileri yüklenirken hata oluştu: $e");
      setState(() {
        _isLoading = false;
        _fullName = "Hata Oluştu";
        _email = "Lütfen tekrar deneyin";
        _profileImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kullanıcı bilgileri yüklenirken bir hata oluştu.'),
        ),
      );
    }
  }

  void _onProfileUpdated() {
    _loadUserDataAndProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Status bar rengini ayarla
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: primaryColor,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundFieldColor,
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  children: [
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
                            backgroundImage:
                                _profileImageUrl != null &&
                                        _profileImageUrl!.isNotEmpty
                                    ? NetworkImage(_profileImageUrl!)
                                    : const AssetImage('assets/profile.jpg')
                                        as ImageProvider,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 70),

                    Text(
                      _fullName,
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: labelTextColor,
                      ),
                    ),
                    Text(
                      _email,
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
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AccountScreen(),
                                ),
                              );
                              _onProfileUpdated();
                            },
                          ),
                          _buildProfileTile(
                            icon: Icons.favorite,
                            title: "Etkinliklerim",
                            onTap: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => MyEventsPage(userId: user.uid),
                                  ),
                                );
                              }
                            },
                          ),
                          _buildProfileTile(
                            icon: Icons.logout,
                            title: "Çıkış Yap",
                            onTap: () async {
                              await FirebaseAuth.instance.signOut();
                              final prefs =
                                  await SharedPreferences.getInstance();
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
