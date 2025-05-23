import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:join_up/event_screen.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Bildirimler")),
        body: const Center(child: Text("Giriş yapılmadı.")),
      );
    }

    final eventsRef = FirebaseFirestore.instance
        .collection('events')
        .where('creatorId', isEqualTo: currentUserId);

    final userNotificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    return Scaffold(
      appBar: AppBar(title: const Text("Bildirimler"), centerTitle: true),
      body: Column(
        children: [
          // Katılımcı bildirimleri
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userNotificationsRef.snapshots(),
              builder: (context, notificationSnapshot) {
                if (!notificationSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications = notificationSnapshot.data!.docs;

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text("Katılımcı bildiriminiz yok."),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notif = notifications[index];
                    final eventTitle = notif['eventTitle'] ?? "Etkinlik";

                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Etkinliğe katılım onaylandı"),
                      subtitle: Text("Etkinlik: $eventTitle"),
                      trailing:
                          notif['read'] == false
                              ? const Icon(
                                Icons.fiber_new,
                                color: Colors.purple,
                              )
                              : null,
                      onTap: () async {
                        await notif.reference.update({'read': true});
                        final data =
                            notif.data()
                                as Map<String, dynamic>?; // null olabilir
                        final eventId = data != null ? data['eventId'] : null;
                        if (eventId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(
                                    eventId: eventId!,
                                    eventName: eventTitle,
                                  ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Etkinlik bilgisi bulunamadı"),
                            ),
                          );
                        }
                      },
                    );
                  },
                );
              },
            ),
          ),

          // Etkinlik sahibi için gelen istekler
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: eventsRef.snapshots(),
              builder: (context, eventSnapshot) {
                if (!eventSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final eventDocs = eventSnapshot.data!.docs;

                if (eventDocs.isEmpty) {
                  return const Center(
                    child: Text("Henüz etkinlik bildiriminiz yok."),
                  );
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
                                    .where('status', isEqualTo: 'pending')
                                    .snapshots(),
                            builder: (context, requestSnapshot) {
                              if (!requestSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final requests = requestSnapshot.data!.docs;
                              if (requests.isEmpty) {
                                return const SizedBox.shrink();
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children:
                                    requests.map((requestDoc) {
                                      return Card(
                                        child: ListTile(
                                          title: Text("Etkinlik: $eventTitle"),
                                          subtitle: FutureBuilder<
                                            DocumentSnapshot
                                          >(
                                            future:
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(requestDoc['userId'])
                                                    .get(),
                                            builder: (context, userSnapshot) {
                                              if (userSnapshot
                                                      .connectionState ==
                                                  ConnectionState.waiting) {
                                                return const SizedBox.shrink(); // yüklenirken boş gösterir
                                              }
                                              if (!userSnapshot.hasData ||
                                                  !userSnapshot.data!.exists) {
                                                return const Text(
                                                  "İstek gönderen: Bilinmiyor",
                                                );
                                              }
                                              final userData =
                                                  userSnapshot.data!.data()
                                                      as Map<String, dynamic>;
                                              final fullName =
                                                  userData['fullName'] ??
                                                  "Ad Soyad";
                                              return Text(
                                                "İstek gönderen: $fullName",
                                              );
                                            },
                                          ),

                                          trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                ),
                                                onPressed: () async {
                                                  // Onaylama işlemleri (senin mevcut kodun)
                                                  await requestDoc.reference
                                                      .update({
                                                        'status': 'approved',
                                                      });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('events')
                                                      .doc(eventDoc.id)
                                                      .collection('attendees')
                                                      .add({
                                                        'userId':
                                                            requestDoc['userId'],
                                                        'joinedAt':
                                                            FieldValue.serverTimestamp(),
                                                      });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(requestDoc['userId'])
                                                      .collection(
                                                        'attendedEvents',
                                                      )
                                                      .add({
                                                        'eventId':
                                                            eventDoc
                                                                .id, // 🔧 EKLENDİ
                                                        'eventTitle':
                                                            eventTitle,
                                                        'eventLocation':
                                                            eventDoc['location'],
                                                        'joinedAt':
                                                            FieldValue.serverTimestamp(),
                                                      });

                                                  // Katılımcıya bildirim gönder
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(requestDoc['userId'])
                                                      .collection(
                                                        'notifications',
                                                      )
                                                      .add({
                                                        'eventId': eventDoc.id,
                                                        'eventTitle':
                                                            eventTitle,
                                                        'timestamp':
                                                            FieldValue.serverTimestamp(),
                                                        'read': false,
                                                      });

                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                        "Katılım onaylandı",
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
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
          ),
        ],
      ),
    );
  }
}

// Event detay sayfası, eventId alıyor
class EventDetailPage extends StatelessWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  Widget build(BuildContext context) {
    final eventRef = FirebaseFirestore.instance
        .collection('events')
        .doc(eventId);

    return Scaffold(
      appBar: AppBar(title: const Text('Etkinlik Detayı')),
      body: FutureBuilder<DocumentSnapshot>(
        future: eventRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Etkinlik bulunamadı"));
          }
          final eventData = snapshot.data!.data() as Map<String, dynamic>;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  eventData['title'] ?? 'Başlık yok',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  eventData['description'] ?? 'Açıklama yok',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),
                Text(
                  "Konum: ${eventData['location'] ?? 'Bilinmiyor'}",
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
