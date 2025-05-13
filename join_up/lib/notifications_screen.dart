import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    // Kullanıcı giriş yapmamışsa, giriş yapılmadı mesajı gösteriyoruz
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bildirimler")),
        body: const Center(child: Text("Giriş yapılmadı.")),
      );
    }

    // Kullanıcıya ait etkinliklerin referansını alıyoruz
    final eventsRef = FirebaseFirestore.instance
        .collection('events')
        .where('creatorId', isEqualTo: currentUserId);

    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: eventsRef.snapshots(),
        builder: (context, eventSnapshot) {
          if (!eventSnapshot.hasData) return const CircularProgressIndicator();
          final eventDocs = eventSnapshot.data!.docs;

          if (eventDocs.isEmpty) {
            return const Center(child: Text("Henüz bildiriminiz yok."));
          }

          return ListView(
            children:
                eventDocs.expand((eventDoc) {
                  final eventTitle = eventDoc['title'];

                  return [
                    StreamBuilder<QuerySnapshot>(
                      stream:
                          eventDoc.reference
                              .collection('joinRequests')
                              .where(
                                'status',
                                isEqualTo: 'pending',
                              ) // Bekleyen istekleri getir
                              .snapshots(),
                      builder: (context, requestSnapshot) {
                        if (!requestSnapshot.hasData)
                          return const SizedBox.shrink();

                        final requests = requestSnapshot.data!.docs;

                        if (requests.isEmpty) return const SizedBox.shrink();

                        // İstekleri listeleyen kısmı
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              requests.map((requestDoc) {
                                return Card(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  child: ListTile(
                                    title: Text("Etkinlik: $eventTitle"),
                                    subtitle: Text(
                                      "İstek gönderen: ${requestDoc['userId']}",
                                    ), // İstek gönderen kullanıcı ID'si
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Onay butonu
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check,
                                            color: Colors.green,
                                          ),
                                          onPressed: () async {
                                            // Katılım isteğini onaylama
                                            await requestDoc.reference.update({
                                              'status': 'approved',
                                            });

                                            // Katılımcıyı etkinlik sahibinin etkinlik listesine ekleme
                                            await FirebaseFirestore.instance
                                                .collection('events')
                                                .doc(eventDoc.id)
                                                .collection('attendees')
                                                .add({
                                                  'userId':
                                                      requestDoc['userId'],
                                                  'joinedAt':
                                                      FieldValue.serverTimestamp(),
                                                });

                                            // Katılımcıyı kendi katıldığı etkinlikler listesine ekleme
                                            await FirebaseFirestore.instance
                                                .collection('users')
                                                .doc(requestDoc['userId'])
                                                .collection('attendedEvents')
                                                .add({
                                                  'eventTitle': eventTitle,
                                                  'eventLocation':
                                                      eventDoc['location'],
                                                  'joinedAt':
                                                      FieldValue.serverTimestamp(),
                                                });

                                            // SnackBar ile kullanıcıyı bilgilendirme
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  "Katılım onaylandı",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        // Reddetme butonu
                                        IconButton(
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                          onPressed: () {
                                            // İstek reddedildiğinde durumu güncelliyoruz
                                            requestDoc.reference.update({
                                              'status': 'rejected',
                                            });
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    ),
                  ];
                }).toList(),
          );
        },
      ),
    );
  }
}
