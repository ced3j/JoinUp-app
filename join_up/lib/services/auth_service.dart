import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Kullanıcı kayıt olma
  Future<User?> signUpWithEmailPassWord(String email, String password) async{
    try{
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return userCredential.user;
    } catch(e){
      print("Kayıt olma hatası: $e");
      return null;
    }
  }


  // Kullanıcı giriş yapma

  Future<User?> signInWithEmailPassword(String email, String password) async{
    try{
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password
        );
        return userCredential.user;
    } catch(e){
      print("Giriş yapma hatası $e");
      return null;
    }
  }



  // Çıkış yapma
  Future<void> signOut() async{
    await auth.signOut();
    print("Kullanıcı çıkış yaptı.");
  }
}