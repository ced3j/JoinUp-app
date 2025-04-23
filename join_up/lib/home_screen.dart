import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:join_up/signup_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State {
  TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Renkler
    const Color primaryColor = Color(0xFF6F2DBD); // Mor ton
    const Color darkColor = Color(0xFF0E1116); // Koyu renk

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ana Sayfa', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),

      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Row(
              children: [
                // Filtre butonu
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: IconButton(
                    onPressed: () {
                      print("Filtre butonuna tıklandı!");
                    },
                    icon: const Icon(Icons.filter_list, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),

                // Arama çubuğu
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Etkinlik Ara...",
                      hintStyle: TextStyle(color: darkColor.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {}); // Yazı yazıldıkça durumu güncelleyecek
                    },
                  ),
                ),

                // Arama ikonu
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: IconButton(
                    onPressed: () {
                      print(
                        'Arama butonuna tıklandı: ${searchController.text}',
                      );
                    },
                    icon: const Icon(Icons.search, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(LucideIcons.calendar),
                    title: Text('Etkinlik Başlığı $index'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Açıklama $index'),
                        Text('Konum: Şehir $index'),
                      ],
                    ),
                    trailing: const Icon(LucideIcons.chevronRight),
                    onTap: () {
                      // Etkinlik detaylarına git
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Seçili öğeyi belirtmek için
        onTap: (index) {
          switch (index) {
            case 0: // Ana Sayfa
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1: // Etkinlik Oluştur
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ), // Daha sonradan bu yönlendirilen sayfalar değişecek
              );
              break;
            case 2: // Profil
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupPage(),
                ), // Daha sonradan bu yönlendirilen sayfalar değişecek
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ana Sayfa'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Etkinlik Oluştur',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}
