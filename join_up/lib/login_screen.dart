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
      appBar: AppBar(title: Text("Giriş Yap")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildUsernameField(), // Kullanıcı adı kısmı
              SizedBox(height: 20),
              buildPasswordField(),
              SizedBox(height: 20),
              buildLoginButton(),
            ],
          ),
        ),
      ),
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
}