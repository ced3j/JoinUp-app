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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            height:
                MediaQuery.of(context).size.height *
                0.65, // %65 ekran yüksekliği
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  "Etkinlik: $eventTitle",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text("Katılım için isteğini onaylaması gerekiyor."),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("İptal"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6F2DBD),
                        foregroundColor: Colors.white,
                      ),
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
                                          title: const Text("Uyarı"),
                                          content: const Text(
                                            "Bu etkinliğe daha önce istek gönderdiniz.",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed:
                                                  () => Navigator.pop(context),
                                              child: const Text("Tamam"),
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
                                        title: const Text("Başarılı"),
                                        content: const Text(
                                          "İstek gönderildi.",
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed:
                                                () => Navigator.pop(context),
                                            child: const Text("Tamam"),
                                          ),
                                        ],
                                      ),
                                );
                              },
                      child: const Text("İstek Gönder"),
                    ),
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
    // const Color darkColor = Color(0xFF0E1116); // darkColor kullanılmadığı için kaldırıldı.

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
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                // Filtre butonu
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
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
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ), // darkColor yerine doğrudan Colors.black kullandım
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 10,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),

                // Arama ikonu
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
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
                  return const Center(child: CircularProgressIndicator());
                }

                var events = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    var eventId = event.id;
                    final eventTitle = event['title'];
                    final creatorId = event['creatorId'];
                    var favorideMi = favoriEvents.contains(eventId);

                    String locationText = 'Konum Bilgisi Yok';
                    final dynamic locationData =
                        event['location']; // dynamic olarak okuyalım

                    // Konum verisinin tipini kontrol et
                    if (locationData is GeoPoint) {
                      // Eğer GeoPoint ise, enlem ve boylamı al
                      locationText =
                          'Enlem: ${locationData.latitude.toStringAsFixed(4)}, Boylam: ${locationData.longitude.toStringAsFixed(4)}';
                    } else if (locationData is String &&
                        locationData.isNotEmpty) {
                      // Eğer String ise, doğrudan kullan
                      locationText = 'Konum: $locationData';
                    }
                    // Eğer null veya başka bir tipte ise varsayılan 'Konum Bilgisi Yok' kalır.

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: const Icon(LucideIcons.calendar),
                        title: Text(eventTitle),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event['description']),
                            Text('Konum: $locationText'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favorideMi ? LucideIcons.star : LucideIcons.starOff,
                            color: favorideMi ? Colors.amber : Colors.grey,
                          ),
                          onPressed: () {
                            toggleFavori(eventId);
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
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: // Ana Sayfa
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
              break;
            case 1: // Etkinlik Oluştur
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateEventPage(userId: currentUser.uid),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Etkinlik oluşturmak için giriş yapmalısınız.',
                    ),
                  ),
                );
              }
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
