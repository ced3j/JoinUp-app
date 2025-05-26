import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'event_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class FavoritesPage extends StatefulWidget {
  final Set<String> favorites;
  final Function(String) toggleFavori;

  const FavoritesPage({
    Key? key,
    required this.favorites,
    required this.toggleFavori,
  }) : super(key: key);

  @override
  _FavorilerSayfasiState createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavoritesPage> {
  late Future<List<Map<String, dynamic>>> _favoriEtkinlikler;

  @override
  void initState() {
    super.initState();
    _favoriEtkinlikler = _getFavoriteEventDetails();
  }

  Future<void> toggleFavori(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(eventId);

    final doc = await favRef.get();

    if (doc.exists) {
      await favRef.delete(); // Favoriden çıkar
    } else {
      await favRef.set({
        'timestamp': FieldValue.serverTimestamp(),
      }); // Favoriye ekle
    }
  }

  Future<List<Map<String, dynamic>>> _getFavoriteEventDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final firestore = FirebaseFirestore.instance;
    final favSnapshot =
        await firestore
            .collection('users')
            .doc(user.uid)
            .collection('favorites')
            .get();

    List<Map<String, dynamic>> etkinlikler = [];

    for (var doc in favSnapshot.docs) {
      String eventId = doc.id;
      DocumentSnapshot eventDoc =
          await firestore.collection('events').doc(eventId).get();

      if (eventDoc.exists) {
        final data = eventDoc.data() as Map<String, dynamic>;
        data['id'] = eventId;
        etkinlikler.add(data);
      }
    }

    return etkinlikler;
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Favori Etkinlikler',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _favoriEtkinlikler,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Favori etkinlik bulunamadı."));
          }

          final etkinlikler = snapshot.data!;

          return ListView.builder(
            itemCount: etkinlikler.length,
            itemBuilder: (context, index) {
              final event = etkinlikler[index];
              final eventId = event['id'];
              final title = event['title'] ?? 'Başlıksız';
              final location = event['locationName'] ?? 'Konum belirtilmemiş';

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: Text(title),
                  subtitle: Text(location),
                  trailing: IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete,
                        color: Colors.grey[800],
                        size: 22,
                      ),
                    ),
                    onPressed: () async {
                      await toggleFavori(eventId);
                      setState(() {
                        _favoriEtkinlikler = _getFavoriteEventDetails();
                      });
                    },
                  ),
                  onTap: () async {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) return;

                    final attendeeSnapshot =
                        await FirebaseFirestore.instance
                            .collection('events')
                            .doc(eventId)
                            .collection('attendees')
                            .where('userId', isEqualTo: currentUser.uid)
                            .limit(1)
                            .get();

                    if (attendeeSnapshot.docs.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ChatScreen(
                                eventId: eventId,
                                eventName: title,
                              ),
                        ),
                      );
                    } else {
                      showCustomSnackBar(
                        context,
                        "Bu etkinliğin katılımcısı değilsiniz!",
                        2,
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
