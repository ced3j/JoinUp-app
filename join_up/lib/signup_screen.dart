import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:join_up/services/auth_service.dart';
import 'package:join_up/login_screen.dart';
import 'main.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final AuthService authService = AuthService(); // AuthService başlatalım

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  void signUp() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String username = usernameController.text.trim();

    if (password != confirmPassword) {
      showCustomSnackBar(context, "Şifreler uyuşmuyor!", 2);
      return;
    }

    var user = await authService.signUpWithEmailPassWord(email, password);

    if (user != null) {
      // Firestore'a kullanıcı bilgilerini ekle
      await authService.saveUserToFirestore(user.uid, username, email);

      showCustomSnackBar(context, "Kayıt başarılı!", 1);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } else {
      showCustomSnackBar(context, "Kayıt başarısız!", 2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  buildHeader(),
                  const SizedBox(height: 30),
                  buildUsernameField(),
                  const SizedBox(height: 20),
                  buildEmailField(),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 20),
                  buildConfirmPasswordField(),
                  const SizedBox(height: 60),
                  buildSignUpButton(),
                  const SizedBox(height: 40),
                  buildLoginText(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Column(
      children: [
        Text(
          "Kayıt Ol",
          style: GoogleFonts.montserrat(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF6F2DBD),
            shadows: [
              Shadow(
                color: const Color(0xFF6F2DBD).withOpacity(0.3),
                offset: const Offset(0.0, 4.0),
                blurRadius: 10.0,
              ),
            ],
            letterSpacing: 2.0,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          "Aramıza Katılın",
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF0E1116),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Hesap oluşturarak etkinliklere katılabilir ve yeni insanlarla tanışabilirsiniz",
          style: GoogleFonts.montserrat(
            fontSize: 13,
            color: const Color(0xFF0E1116).withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget buildUsernameField() {
    return TextFormField(
      controller: usernameController,
      style: GoogleFonts.montserrat(),
      decoration: inputDecoration("Kullanıcı Adı", Icons.person_outline),
    );
  }

  Widget buildEmailField() {
    return TextFormField(
      controller: emailController,
      style: GoogleFonts.montserrat(),
      decoration: inputDecoration("Email", Icons.email),
    );
  }

  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      style: GoogleFonts.montserrat(),
      obscureText: obscurePassword,
      decoration: inputDecorationWithVisibility(
        "Şifre",
        Icons.lock_outline,
        () {
          setState(() {
            obscurePassword = !obscurePassword;
          });
        },
      ),
    );
  }

  Widget buildConfirmPasswordField() {
    return TextFormField(
      controller: confirmPasswordController,
      style: GoogleFonts.montserrat(),
      obscureText: obscurePassword,
      decoration: inputDecorationWithVisibility(
        "Tekrar Şifre",
        Icons.lock_outline,
        () {
          setState(() {
            obscurePassword = !obscurePassword;
          });
        },
      ),
    );
  }

  Widget buildSignUpButton() {
    return ElevatedButton(
      onPressed: signUp,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6F2DBD),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
      ),
      child: Text(
        "Kayıt Ol",
        style: GoogleFonts.montserrat(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget buildLoginText() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Zaten bir hesabınız var mı?",
          style: GoogleFonts.montserrat(
            color: const Color(0xFF0E1116),
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          child: Text(
            "Oturum Açın",
            style: GoogleFonts.montserrat(
              color: const Color(0xFF6F2DBD),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: GoogleFonts.montserrat(
        color: const Color(0xFF0E1116).withOpacity(0.6),
      ),
      prefixIcon: Icon(icon, color: const Color(0xFF6F2DBD)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6F2DBD), width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  InputDecoration inputDecorationWithVisibility(
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return inputDecoration(label, icon).copyWith(
      suffixIcon: IconButton(
        icon: Icon(
          obscurePassword ? Icons.visibility_off : Icons.visibility,
          color: const Color(0xFF6F2DBD),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
