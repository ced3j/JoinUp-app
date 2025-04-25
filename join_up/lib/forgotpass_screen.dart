// Gerekli Flutter Material kütüphanesini içe aktarır
import 'package:flutter/material.dart';



// ForgotPasswordPage adında bir StatefulWidget tanımlıyoruz
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  // State nesnesini oluşturur
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}



// Widget'ın durumunu yöneten sınıf
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // E-posta girişini kontrol etmek için TextEditingController
  final TextEditingController _emailController = TextEditingController();

  // Widget ağacını oluşturan build metodu
  @override
  Widget build(BuildContext context) {
    // Sabit renk tanımlamaları
    const Color primaryColor = Color(0xFF6F2DBD); // Mor ton
    const Color darkColor = Color(0xFF0E1116); // Koyu renk

    return Scaffold(
      // Uygulama çubuğu (AppBar)
      appBar: AppBar(
        title: const Text(
          "Şifremi Unuttum",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      // Ekranın ana gövdesi
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Kenar boşlukları

        child: Column(
          children: [
            Image.asset("palm-recognition.png",),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,

              children: [
                  // Başlık metni
                  const Text(
                    "E-posta adresinizi girin",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkColor,
                    ),
                  ),
                  const SizedBox(height: 8), // Boşluk
                  // Talimat metni
                  const Text(
                    "Şifre sıfırlama bağlantısı e-posta adresinize gönderilecektir.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 24), // Boşluk
                  // E-posta giriş alanı
                  TextField(
                    controller: _emailController, // TextEditingController bağlama
                    decoration: const InputDecoration(
                      labelText: "E-posta",
                      hintText: "ornek@eposta.com",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress, // E-posta klavyesi
                  ),
                  const SizedBox(height: 24), // Boşluk
                  // Gönder butonu
                  ElevatedButton(
                    onPressed: () {
                      // Butona basıldığında çalışacak kod
                      String email = _emailController.text;
                      if (email.isNotEmpty) {
                        // Burada e-posta ile şifre sıfırlama işlemi yapılabilir
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Bağlantı $email adresine gönderildi")),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Lütfen e-posta adresinizi girin")),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor, // Buton arka plan rengi
                      foregroundColor: Colors.white, // Buton metin/simgesi rengi
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      "Gönder",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],

            ),
          ],
        ),
      ),
    );
  }

  // Widget yok edildiğinde controller'ı temizler
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
