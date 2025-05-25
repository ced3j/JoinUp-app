import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  late Future<String> _imageUrlFuture;

  @override
  void initState() {
    super.initState();
    _imageUrlFuture = _getImageUrlFromFirebaseStorage();
  }

  // Firebase Storage'dan görsel URL'si alma
  Future<String> _getImageUrlFromFirebaseStorage() async {
    try {
      final ref = FirebaseStorage.instance.ref().child("palm-recognition.png");
      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint("Görsel alınamadı: $e");
      return ''; // Boş dönerse hata ikonunu göstereceğiz
    }
  }

  // Şifre sıfırlama işlemi
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen e-posta adresinizi girin")),
      );
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Şifre sıfırlama bağlantısı $email adresine gönderildi.",
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Hata: ${e.toString()}")));
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD);
    const Color darkColor = Color(0xFF0E1116);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Şifremi Unuttum",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FutureBuilder<String>(
              future: _imageUrlFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError || snapshot.data == '') {
                  return const Icon(Icons.image_not_supported, size: 100);
                } else {
                  return CachedNetworkImage(
                    imageUrl: snapshot.data!,
                    width: 250,
                    height: 250,
                    placeholder:
                        (context, url) => const CircularProgressIndicator(),
                    errorWidget:
                        (context, url, error) =>
                            const Icon(Icons.image_not_supported, size: 100),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            const Text(
              "E-posta adresinizi girin" ,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkColor
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Şifre sıfırlama bağlantısı e-posta adresinize gönderilecektir.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "E-posta",
                hintText: "ornek@eposta.com",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6F2DBD),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Gönder", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
