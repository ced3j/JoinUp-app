import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Kullanıcı kayıt olma
  Future<User?> signUpWithEmailPassWord(String email, String password) async {
    try {
      // Firebase ile kullanıcı oluşturma
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Başarıyla kayıt olduktan sonra kullanıcıyı döndür
      User? user = userCredential.user;
      if (user != null) {
        print("Kayıt başarılı, UID: ${user.uid}");
      }
      return user;
    } catch (e) {
      print("Kayıt olma hatası: $e");
      return null;
    }
  }

  Future<void> saveUserToFirestore(
    String uid,
    String fullName,
    String email,
  ) async {
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'fullName': fullName,
      'email': email,
    });
  }

  // Kullanıcı giriş yapma
  Future<User?> signInWithEmailPassword(String email, String password) async {
    try {
      // Firebase ile giriş yapma
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Giriş başarılı ise kullanıcıyı döndür
      User? user = userCredential.user;
      if (user != null) {
        print("Giriş başarılı, UID: ${user.uid}");
      }
      return user;
    } catch (e) {
      print("Giriş yapma hatası: $e");
      return null;
    }
  }

  // Çıkış yapma
  Future<void> signOut() async {
    await auth.signOut();
    print("Kullanıcı çıkış yaptı.");
  }
}
