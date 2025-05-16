import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:join_up/Notifications_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:join_up/favorite_event_screen.dart';
import 'package:join_up/createEvent_screen.dart'; // Etkinlik oluşturma sayfasının importu
import 'package:join_up/profile_screen.dart'; // Profil sayfasının importu
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  final Set<String> favoriEvents =
      {}; // Favori etkinliklerin ID'lerini tutuyoruz

  // Favori ekleme/çıkarma fonksiyonu
  void toggleFavori(String eventId) {
    setState(() {
      if (favoriEvents.contains(eventId)) {
        favoriEvents.remove(eventId); // Etkinlik favorilerden çıkar
      } else {
        favoriEvents.add(eventId); // Etkinlik favorilere eklenir
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showJoinRequestSheet(
    BuildContext context,
    String eventId,
    String eventTitle,
    String creatorId,
  ) {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

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
            height:
                MediaQuery.of(context).size.height *
                0.65, // %60 ekran yüksekliği
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
                Text("Katılım için isteğini onaylaması gerekiyor."),
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
                      onPressed:
                          currentUserId == creatorId
                              ? null
                              : () async {
                                final joinRequestRef = FirebaseFirestore
                                    .instance
                                    .collection('events')
                                    .doc(eventId)
                                    .collection('joinRequests');

                                // Daha önce istek gönderilmiş mi kontrolü
                                final existingRequest =
                                    await joinRequestRef
                                        .where(
                                          'userId',
                                          isEqualTo: currentUserId,
                                        )
                                        .limit(1)
                                        .get();

                                if (existingRequest.docs.isNotEmpty) {
                                  // Zaten istek varsa AlertDialog göster
                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: Text("Uyarı"),
                                          content: Text(
                                            "Bu etkinliğe daha önce istek gönderdiniz.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: Text("Tamam"),
                                            ),
                                          ],
                                        ),
                                  );
                                  return;
                                }

                                // İstek gönderiliyor
                                await joinRequestRef.add({
                                  'userId': currentUserId,
                                  'status': 'pending',
                                  'createdAt': FieldValue.serverTimestamp(),
                                });

                                // Bildirim gönderiliyor
                                await FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(creatorId)
                                    .collection('notifications')
                                    .add({
                                      'type': 'join_request',
                                      'message':
                                          '$currentUserId etkinliğinize katılmak için istek gönderdi.',
                                      'eventId': eventId,
                                      'createdAt': FieldValue.serverTimestamp(),
                                    });

                                // Popup'ı kapat
                                Navigator.pop(context);

                                // Başarılı AlertDialog göster
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text("Başarılı"),
                                        content: Text("İstek gönderildi."),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: Text("Tamam"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                    )

                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  builder:
                      (context) => FavoritesPage(
                        favorites: favoriEvents, // Favori etkinliklerin ID'leri
                        toggleFavori:
                            toggleFavori, // Favori ekleme/çıkarma fonksiyonu
                      ),
                ),
              ).then((_) {
                setState(
                  () {},
                ); // Favoriler sayfasından döndüğümüzde listeyi güncelle
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              //bildirimler sayfasına git
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsPage(),
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
                      setState(() {});
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
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('events').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                var events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    var eventId =
                        event.id; // Etkinliğin benzersiz ID'sini alıyoruz
                    final eventTitle = event['title']; // Etkinlik Başlığı
                    final creatorId = event['creatorId'];
                    var favorideMi = favoriEvents.contains(eventId);

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(LucideIcons.calendar),
                        title: Text(eventTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['description']),
                            Text('Konum: ${event['location']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favorideMi ? LucideIcons.star : LucideIcons.starOff,
                            color: favorideMi ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            toggleFavori(
                              eventId,
                            ); // Yıldız tıklandığında favori ekle/çıkar
                          },
                        ),
                        onTap: () {
                          showJoinRequestSheet(
                            context,
                            eventId,
                            eventTitle,
                            creatorId,
                          );
                        },
                      ),
                    );
                  },
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
                  builder:
                      (context) =>
                          const CreateEventPage(userId: "current_user_id"),
                ),
              );
              break;
            case 2: // Profil
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
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
