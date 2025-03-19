import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
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
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
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
                  logoField(),
                  const SizedBox(height: 80),
                  buildUsernameField(),
                  const SizedBox(height: 20),
                  buildPasswordField(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Şifremi Unuttum",
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF6F2DBD),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  buildLoginButton(),
                  const SizedBox(height: 40),
                  Text(
                    "veya şununla giriş yapın",
                    style: GoogleFonts.montserrat(
                      color: const Color(0xFF0E1116),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      socialLoginButton(
                        icon: 'assets/google_icon.png',
                        onPressed: () {
                          print("Google ile giriş yapılıyor...");
                        },
                        iconColor: Colors.red,
                        fallbackIcon: Icons.g_mobiledata,
                      ),
                      const SizedBox(width: 20),
                      socialLoginButton(
                        icon: 'assets/facebook_icon.png',
                        onPressed: () {
                          print("Facebook ile giriş yapılıyor...");
                        },
                        iconColor: Colors.blue,
                        fallbackIcon: Icons.facebook,
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Hesabınız yok mu?",
                        style: GoogleFonts.montserrat(
                          color: const Color(0xFF0E1116),
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Kaydolun",
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

  Widget logoField() {
    return Text(
      "JoinUp",
      style: GoogleFonts.montserrat(
        fontSize: 50,
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
    );
  }

  Widget buildUsernameField() {
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

  Widget buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          String username = usernameController.text;
          String password = passwordController.text;
          print("Kullanıcı Adı: $username, Şifre: $password");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6F2DBD),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          "Giriş Yap",
          style: GoogleFonts.montserrat(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget socialLoginButton({
    required String icon,
    required VoidCallback onPressed,
    required Color iconColor,
    required IconData fallbackIcon,
  }) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(
          fallbackIcon,
          size: 35,
          color: iconColor,
        ),
      ),
    );
  }
}