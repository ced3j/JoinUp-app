import 'package:flutter/material.dart';
import 'package:join_up/favorite_event_screen.dart';
import 'package:join_up/profile_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:join_up/createEvent_screen.dart';
import 'package:join_up/notifications_screen.dart';

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
final Set<int> favoriEvents = {};

 void toggleFavori(int index) {
    setState(() {
      if (favoriEvents.contains(index)) {
        favoriEvents.remove(index);
      } else {
        favoriEvents.add(index);
      }
    });
  }





void showJoinRequestSheet(BuildContext context, String eventTitle) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.all(16),
          height: MediaQuery.of(context).size.height * 0.65, // %60 ekran yüksekliği
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Etkinlik: $eventTitle",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Açıklama burada yer alacak.\nKatılım için isteğini onaylaması gerekiyor.",
              ),
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: Text("İptal"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6F2DBD),
                      foregroundColor: Colors.white,  

                    ),
                    child: Text("İstek Gönder"),
                    onPressed: () {
                      // İstek gönderme işlemi buraya
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("İstek gönderildi")),
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      );
    },
  );
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
        actions: [
        IconButton(
        icon: const Icon(Icons.star),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoritesPage(
                favorites : favoriEvents,
                toggleFavori: toggleFavori,
        ),
      ),
    ).then((_) {
      setState(() {}); // Geri dönünce liste güncellensin
    });
  },
),
      IconButton(
        icon: const Icon(Icons.notifications),
        onPressed: (){
          //Bildirimler Sayfasına git
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=> const NotificationsPage(),
            ),
          );
        },

      ),
        ],
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
                final bool favorideMi = favoriEvents.contains(index);
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
                    trailing: IconButton(
                      icon: Icon(
                        favorideMi ? LucideIcons.star : LucideIcons.starOff,
                        color: favorideMi ? Colors.amber : Colors.grey,                      
                     ),
                     onPressed: (){

                      setState(() {
                        if(favorideMi){

                          favoriEvents.remove(index);
                        }
                        else{
                          favoriEvents.add(index);
                        }
                      });
                     }
                  ),
                    onTap: () {
                        showJoinRequestSheet(context, "Etkinlik Başlığı"); // Etkinlik detaylarına git
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
                  builder: (context) => const CreateEventPage(userId: "current_user_id"),
                ), // Daha sonradan bu yönlendirilen sayfalar değişecek
              );
              break;
            case 2: // Profil
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfilePage(),
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
