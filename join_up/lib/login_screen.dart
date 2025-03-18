import 'package:flutter/material.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget{
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      home: LoginPage(),
    );
  }
}


class LoginPage extends StatelessWidget{
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              logoField(),
              SizedBox(height: 200),
              buildUsernameField(), // Kullanıcı adı kısmı
              SizedBox(height: 20),
              buildPasswordField(),
              SizedBox(height: 20),
              buildLoginButton(),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  googleLoginButton(context),
                  SizedBox(width: 20),
                  facebookLoginButton(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget logoField(){
    return Text(
      "JoinUp",
      style: TextStyle(
        fontSize: 50,
        fontWeight: FontWeight.bold,
        color: Colors.blue[900],
        shadows: [
          Shadow(
            color: const Color.fromARGB(255, 240, 43, 43).withValues(alpha: 1.0),
            offset: Offset(0.0, 0.0),
            blurRadius: 15.0,
          ),
          Shadow(
            color: const Color.fromARGB(255, 240, 43, 43).withValues(alpha: 1.0),
            offset: Offset(0.0, 0.0),
            blurRadius: 10.0,
          ),
          Shadow(
            color: const Color.fromARGB(255, 240, 43, 43).withValues(alpha: 1.0),
            offset: Offset(0.0, 0.0),
            blurRadius: 5.0,
          ),
        ],
        letterSpacing: 2.0,
        decorationColor: Colors.blue[200],
        decorationStyle: TextDecorationStyle.solid,
      ),
      textAlign: TextAlign.center,
    );
  }




  Widget buildUsernameField(){
    return TextFormField(
      controller: usernameController,
      decoration: InputDecoration(
        labelText: "Kullanıcı Adı",
        border: OutlineInputBorder(),
      ),
    );
  }




  Widget buildPasswordField(){
    return TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: "Şifre",
        border: OutlineInputBorder(),
      ),
    );
  }


  Widget buildLoginButton() {
      return ElevatedButton(
        onPressed: () {
          String username = usernameController.text;
          String password = passwordController.text;
          print("Kullanıcı Adı: $username, Şifre: $password");
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        ),
        child: Text("Giriş Yap", style: TextStyle(fontSize: 18, color: Colors.white)),
      );
    }


  Widget googleLoginButton(BuildContext context) {
    return SizedBox(
      width: 30, // Buton genişliği
      height: 30, // Buton yüksekliği
      child: FloatingActionButton(
        onPressed: () {
          // Google ile giriş simülasyonu
          print("Google ile giriş yapılıyor...");
          // Gerçek uygulamada burada Firebase Authentication ile Google Sign-In entegre edilir
        },
        backgroundColor: Colors.white, // Beyaz arka plan
        elevation: 4.0, // Gölge efekti
        child: Icon(
          Icons.star, // Google logosu yerine geçici bir ikon (resmi Google ikonu için asset kullanılabilir)
          size: 30,
          color: Colors.red[700], // Google’un kırmızı tonu
        ),
        shape: CircleBorder(), // Yuvarlak şekil
      ),
    );
  }

  Widget facebookLoginButton(BuildContext context){
    return SizedBox(
      width: 30,
      height: 30,
      child: FloatingActionButton(
        onPressed: () {
          print("Facebook ile giriş yapılıyor...");
        },
        backgroundColor: Colors.white,
        elevation: 4.0,
        child: Icon(
          Icons.facebook,
          size: 30,
          color: Colors.blue[800],
        ),
        shape: CircleBorder(),
      ),
    );
  }


}