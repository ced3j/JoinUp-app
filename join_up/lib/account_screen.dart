import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

const Color primaryColor = Color(0xFF6F2DBD);
const Color accentColor = Color(0xFFFFD600);
const Color backgroundFieldColor = Color(0xFFFEF7FF);
const Color labelTextColor = Color(0xFF0E1116);

class AccountScreen extends StatefulWidget {
  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      final data = doc.data();
      if (data != null) {
        setState(() {
          _fullNameController.text = data['fullName'] ?? '';
          _emailController.text = user.email ?? '';
        });
      }
    }
  }

  Future<void> _updateUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (user == null || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen tüm alanları doldurun.")),
      );
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      if (email != user.email) {
        await user.updateEmail(email);
      }

      await firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler başarıyla güncellendi.')),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu.';
      if (e.code == 'wrong-password') {
        message = 'Girilen şifre yanlış.';
      } else if (e.code == 'invalid-credential') {
        message = 'Kimlik doğrulama başarısız oldu.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanımda.';
      } else if (e.code == 'requires-recent-login') {
        message = 'Bu işlem için tekrar giriş yapmanız gerekiyor.';
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $message")));
    }
  }

  Future<void> _changePassword() async {
    if (!_passwordFormKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    final oldPassword = _oldPasswordController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmNewPassword = _confirmNewPasswordController.text.trim();

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Kullanıcı bulunamadı.")));
      return;
    }

    if (newPassword != confirmNewPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Yeni şifreler eşleşmiyor.")),
      );
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifre başarıyla güncellendi.")),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmNewPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = "Bir hata oluştu.";
      if (e.code == 'wrong-password') {
        message = "Eski şifre yanlış.";
      } else if (e.code == 'weak-password') {
        message = "Yeni şifre çok zayıf.";
      } else if (e.code == 'requires-recent-login') {
        message = "Bu işlem için tekrar giriş yapmanız gerekiyor.";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: $message")));
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundFieldColor,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            const SizedBox(height: 70),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Hesap Bilgileri Güncelle",
                        style: GoogleFonts.montserrat(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildInputField(
                            "İsim Soyisim",
                            _fullNameController,
                            Icons.person_outline,
                          ),
                          const SizedBox(height: 20),
                          buildInputField(
                            "Email",
                            _emailController,
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 20),
                          buildInputField(
                            "Şifre (Kimlik Doğrulama)",
                            _passwordController,
                            Icons.lock_outline,
                            obscureText: _obscurePassword,
                            obscureToggle: () {
                              setState(
                                () => _obscurePassword = !_obscurePassword,
                              );
                            },
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 140,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _updateUserInfo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Güncelle",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 53, 0, 71),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                    Form(
                      key: _passwordFormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Şifre Güncelle",
                            style: GoogleFonts.montserrat(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          buildInputField(
                            "Eski Şifre",
                            _oldPasswordController,
                            Icons.lock_outline,
                            obscureText: _obscureOldPassword,
                            obscureToggle: () {
                              setState(
                                () =>
                                    _obscureOldPassword = !_obscureOldPassword,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          buildInputField(
                            "Yeni Şifre",
                            _newPasswordController,
                            Icons.lock_reset,
                            obscureText: _obscureNewPassword,
                            obscureToggle: () {
                              setState(
                                () =>
                                    _obscureNewPassword = !_obscureNewPassword,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          buildInputField(
                            "Yeni Şifre Tekrar",
                            _confirmNewPasswordController,
                            Icons.lock_reset,
                            obscureText: _obscureConfirmPassword,
                            obscureToggle: () {
                              setState(
                                () =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword,
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 140,
                              height: 45,
                              child: ElevatedButton(
                                onPressed: _changePassword,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: accentColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Güncelle",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color.fromARGB(255, 53, 0, 71),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Stack(
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
          child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 65,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 65),
                    child: Text(
                      "Hesap Bilgileri",
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: MediaQuery.of(context).size.width / 2 - 50,
          child: CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey[200],
            backgroundImage: const AssetImage('assets/profile.jpg'),
            child: Align(
              alignment: Alignment.bottomRight,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: primaryColor,
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildInputField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    VoidCallback? obscureToggle,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.montserrat(color: labelTextColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.montserrat(
          color: labelTextColor.withOpacity(0.6),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        suffixIcon:
            obscureToggle != null
                ? IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: primaryColor,
                  ),
                  onPressed: obscureToggle,
                )
                : null,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "$label boş bırakılamaz";
        }
        return null;
      },
    );
  }
}
