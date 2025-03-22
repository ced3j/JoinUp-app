import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:join_up/login_screen.dart';

void main(){
  runApp (const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6F2DBD),
          secondary: const Color(0xFF0E1116),
        ),
        textTheme: GoogleFonts.montserratTextTheme(),
        fontFamily: 'Montserrat',
      ),
      home: const SignupPage(),
    );
  }
}

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool obscurePassword = true;

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
                  const SizedBox(height: 80),
                  // Üye ol sayfası yazısı gelebilir
                  const SizedBox(height: 80),
                  buildUsernameField(),
                  const SizedBox(height: 20),
                  buildEmailField(),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 20),
                  buildConfirmPasswordField(),
                  const SizedBox(height: 20),
                  buildSignUpButton(),
                  const SizedBox(height: 40),
                  Row(
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget buildUsernameField(){
    return TextFormField(
      controller: usernameController,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        labelText: "Kullanıcı Adı",
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF0E1116).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          Icons.person_outline,
          color: const Color(0xFF6F2DBD),
        ),
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
      ),
    );
  }


   Widget buildEmailField(){
    return TextFormField(
      controller: usernameController,
      style: GoogleFonts.montserrat(),
      decoration: InputDecoration(
        labelText: "Email",
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF0E1116).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          Icons.email,
          color: const Color(0xFF6F2DBD),
        ),
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
      ),
    );
  }




  Widget buildPasswordField() {
    return TextFormField(
      controller: passwordController,
      style: GoogleFonts.montserrat(),
      obscureText: obscurePassword,
      decoration: InputDecoration(
        labelText: "Şifre",
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF0E1116).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: const Color(0xFF6F2DBD),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6F2DBD),
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
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
      ),
    );
  }


  Widget buildConfirmPasswordField() {
    return TextFormField(
      controller: passwordController,
      style: GoogleFonts.montserrat(),
      obscureText: obscurePassword,
      decoration: InputDecoration(
        labelText: "Tekrar Şifre",
        labelStyle: GoogleFonts.montserrat(
          color: const Color(0xFF0E1116).withOpacity(0.6),
        ),
        prefixIcon: Icon(
          Icons.lock_outline,
          color: const Color(0xFF6F2DBD),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: const Color(0xFF6F2DBD),
          ),
          onPressed: () {
            setState(() {
              obscurePassword = !obscurePassword;
            });
          },
        ),
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
      ),
    );
  }



  Widget buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6F2DBD),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Üye Ol",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }



}