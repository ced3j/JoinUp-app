import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:join_up/event_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId != null) {
      markAllNotificationsRead(currentUserId!);
    }
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final unreadNotifications =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .get();

    for (var doc in unreadNotifications.docs) {
      await doc.reference.update({'read': true});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (currentUserId == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF6F2DBD),
          centerTitle: true,
          title: Text(
            "Bildirimler",
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: const Center(child: Text("Giriş yapılmadı.")),
      );
    }

    final userNotificationsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('notifications')
        .orderBy('timestamp', descending: true);

    final eventsRef = FirebaseFirestore.instance
        .collection('events')
        .where('creatorId', isEqualTo: currentUserId);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F2DBD),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Text(
          "Bildirimler",
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userNotificationsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final notifications =
                    snapshot.data!.docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>?;
                      return data?['type'] == 'joinApproved';
                    }).toList();

                if (notifications.isEmpty) {
                  return const Center(
                    child: Text("Katılımcı bildiriminiz yok."),
                  );
                }

                return ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final data =
                        notifications[index].data() as Map<String, dynamic>;
                    final eventTitle = data['eventTitle'] ?? "Etkinlik";
                    final isRead = data['read'] ?? true; // read yoksa true

                    return ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Etkinliğe katılım onaylandı"),
                      subtitle: Text("Etkinlik: $eventTitle"),
                      trailing:
                          !isRead
                              ? const Icon(
                                Icons.fiber_new,
                                color: Colors.purple,
                              )
                              : null,
                      onTap: () async {
                        await notifications[index].reference.update({
                          'read': true,
                        });
                        final eventId = data['eventId'];
                        if (eventId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ChatScreen(
                                    eventId: eventId,
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
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: eventsRef.snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final events = snapshot.data!.docs;

                if (events.isEmpty) {
                  return const Center(
                    child: Text("Henüz etkinlik bildiriminiz yok."),
                  );
                }

                return ListView(
                  children:
                      events.expand((eventDoc) {
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
                                children:
                                    requests.map((requestDoc) {
                                      final userId = requestDoc['userId'];

                                      return Card(
                                        margin: const EdgeInsets.symmetric(
                                          vertical: 4,
                                          horizontal: 8,
                                        ),
                                        child: ListTile(
                                          title: Text("Etkinlik: $eventTitle"),
                                          subtitle: FutureBuilder<
                                            DocumentSnapshot
                                          >(
                                            future:
                                                FirebaseFirestore.instance
                                                    .collection('users')
                                                    .doc(userId)
                                                    .get(),
                                            builder: (context, userSnapshot) {
                                              if (!userSnapshot.hasData) {
                                                return const SizedBox.shrink();
                                              }
                                              final userData =
                                                  userSnapshot.data!.data()
                                                      as Map<String, dynamic>?;
                                              final fullName =
                                                  userData?['fullName'] ??
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
                                                  await requestDoc.reference
                                                      .update({
                                                        'status': 'approved',
                                                      });

                                                  await eventDoc.reference
                                                      .collection('attendees')
                                                      .add({
                                                        'userId': userId,
                                                        'joinedAt':
                                                            FieldValue.serverTimestamp(),
                                                      });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userId)
                                                      .collection(
                                                        'attendedEvents',
                                                      )
                                                      .add({
                                                        'eventId': eventDoc.id,
                                                        'eventTitle':
                                                            eventTitle,
                                                        'eventLocation':
                                                            eventDoc['location'],
                                                        'joinedAt':
                                                            FieldValue.serverTimestamp(),
                                                      });

                                                  await FirebaseFirestore
                                                      .instance
                                                      .runTransaction((
                                                        transaction,
                                                      ) async {
                                                        final snapshot =
                                                            await transaction
                                                                .get(
                                                                  eventDoc
                                                                      .reference,
                                                                );
                                                        final currentCount =
                                                            (snapshot.data()
                                                                as Map<
                                                                  String,
                                                                  dynamic
                                                                >?)?['currentParticipants'] ??
                                                            0;
                                                        transaction.update(
                                                          eventDoc.reference,
                                                          {
                                                            'currentParticipants':
                                                                currentCount +
                                                                1,
                                                          },
                                                        );
                                                      });

                                                  // Yeni bildirim ekle
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('users')
                                                      .doc(userId)
                                                      .collection(
                                                        'notifications',
                                                      )
                                                      .add({
                                                        'type': 'joinApproved',
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
                                                onPressed: () async {
                                                  await requestDoc.reference
                                                      .update({
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
