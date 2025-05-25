import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

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
  // Bu controller geri geldi! Kullanıcı bilgisi güncelleme için şifre doğrulaması için kullanılacak.
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmNewPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  String selectedProfileUrl =
      ""; // Kullanıcının seçtiği/kaydettiği profil fotoğrafı URL'si

  // Firebase Storage'daki dosya isimleri
  static const List<String> fileNames = [
    "man1.png",
    "man2.png",
    "man3.png",
    "woman1.png",
    "woman2.png",
    "woman3.png",
  ];

  // Bu listeyi Firebase Storage'dan çekilen URL'lerle dolduracağız
  List<String> profileImageUrls = []; // Dynamic olarak doldurulacak

  @override
  void initState() {
    super.initState();
    // Önce profil resim URL'lerini yükle, sonra kullanıcı verisini yükle
    _loadProfileImageUrls().then((_) {
      _loadUserData();
    });
  }

  // Resimlerin indirilebilir URL'lerini Firebase Storage'dan çeker
  Future<void> _loadProfileImageUrls() async {
    List<String> urls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (String fileName in fileNames) {
      try {
        final String downloadUrl =
            await storageRef.child(fileName).getDownloadURL();
        urls.add(downloadUrl);
      } catch (e) {
        print("Error getting download URL for $fileName: $e");
        urls.add(""); // Hata durumunda boş bir URL ekle
      }
    }
    setState(() {
      profileImageUrls = urls;
    });
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
          selectedProfileUrl = data['profileImage'] ?? ""; // Kayıtlı URL'yi çek
        });
      }
    }
  }

  // Sadece isim ve e-posta gibi diğer bilgileri güncelleyen fonksiyon
  Future<void> _updateUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    final firestore = FirebaseFirestore.instance;
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    // Geri gelen şifre alanı
    final password = _passwordController.text.trim();

    if (user == null || password.isEmpty) {
      // Şifre boşsa uyarı ver
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Lütfen kimlik doğrulama şifrenizi girin."),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      // Kimlik doğrulama adımı geri geldi
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // E-posta değiştiyse güncelle
      if (email != user.email) {
        await user.updateEmail(email);
      }

      await firestore.collection('users').doc(user.uid).update({
        'fullName': fullName,
        'email': email,
        // Profil fotoğrafı güncellemesi artık burada değil, doğrudan _showProfileSelectionDialog içinde yapılacak
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bilgiler başarıyla güncellendi.')),
      );
      // Başarılı güncelleme sonrası şifre alanını temizle
      _passwordController.clear();
    } on FirebaseAuthException catch (e) {
      String message = 'Bir hata oluştu.';
      if (e.code == 'wrong-password') {
        message = 'Girilen şifre yanlış.';
      } else if (e.code == 'invalid-credential') {
        message = 'Kimlik doğrulama başarısız oldu.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi zaten kullanımda.';
      } else if (e.code == 'requires-recent-login') {
        message =
            'Bu işlem için tekrar giriş yapmanız gerekiyor (e-posta güncellemesi için).';
      } else if (e.code == 'invalid-email') {
        message = 'Geçersiz e-posta formatı.';
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

  // Profil fotoğrafı seçildiğinde Firestore'a doğrudan kaydeden fonksiyon
  Future<void> _saveProfileImageToFirestore(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'profileImage': imageUrl});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil fotoğrafı güncellendi.')),
        );
      } catch (e) {
        print("Error saving profile image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil fotoğrafı güncellenirken bir hata oluştu.'),
          ),
        );
      }
    }
  }

  void _showProfileSelectionDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        if (profileImageUrls.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: profileImageUrls.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemBuilder: (ctx, index) {
            final url = profileImageUrls[index];
            return GestureDetector(
              onTap: () async {
                // Async yaparak _saveProfileImageToFirestore'u bekleyebiliriz
                setState(() {
                  selectedProfileUrl = url; // UI'ı hemen güncelle
                });
                Navigator.of(context).pop(); // Diyalogu kapat

                // Profil fotoğrafını seçer seçmez Firestore'a kaydet
                await _saveProfileImageToFirestore(url);
              },
              child: CircleAvatar(
                backgroundImage: NetworkImage(url),
                radius: 40,
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose(); // Tekrar dispose ediliyor
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "İsim Soyisim boş bırakılamaz";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          buildInputField(
                            "Email",
                            _emailController,
                            Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Email boş bırakılamaz";
                              }
                              if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return "Geçerli bir email adresi girin";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          // "Şifre (Kimlik Doğrulama)" alanı geri geldi
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Kimlik doğrulama şifresi boş bırakılamaz";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 40),
                          Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 140,
                              height: 45,
                              child: ElevatedButton(
                                onPressed:
                                    _updateUserInfo, // Sadece isim ve e-posta günceller
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Eski şifre boş bırakılamaz";
                              }
                              return null;
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Yeni şifre boş bırakılamaz";
                              }
                              if (value.length < 6) {
                                return "Şifre en az 6 karakter olmalı";
                              }
                              return null;
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
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Yeni şifre tekrar boş bırakılamaz";
                              }
                              if (value != _newPasswordController.text) {
                                return "Şifreler eşleşmiyor";
                              }
                              return null;
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
          child: GestureDetector(
            onTap: () => _showProfileSelectionDialog(context),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[200],
              // selectedProfileUrl boşsa veya doğru URL gelmediyse varsayılan resim
              backgroundImage:
                  selectedProfileUrl.isNotEmpty
                      ? NetworkImage(selectedProfileUrl)
                      : const AssetImage('assets/profile.jpg') as ImageProvider,
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
    String? Function(String?)? validator, // Validator parametresi
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
      validator: validator, // Validator kullanılıyor
    );
  }
}
