import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_screen.dart'; // sohbet ekranını import et

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Oluşturduğum etkinlikleri çek
  Future<List<Event>> getCreatedEvents(String userId) async {
    final snapshot =
        await _firestore
            .collection('events')
            .where('creatorId', isEqualTo: userId)
            .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      DateTime duration;
      final rawDuration = data['duration'];

      if (rawDuration is Timestamp) {
        duration = rawDuration.toDate();
      } else if (rawDuration is String) {
        duration = DateTime.tryParse(rawDuration) ?? DateTime.now();
      } else {
        duration = DateTime.now();
      }

      // GeoPoint ise stringe çevir
      String location = '';
      if (data['location'] != null) {
        final loc = data['location'];
        if (loc is GeoPoint) {
          location = '${loc.latitude}, ${loc.longitude}';
        } else if (loc is String) {
          location = loc;
        }
      }

      return Event(
        eventId: doc.id,
        title: data['title'] ?? '',
        location: location,
        description: data['description'] ?? '',
        gender: data['gender'] ?? '',
        duration: duration,
        creatorId: data['creatorId'] ?? '',
        eventType: data['eventType'] ?? '',  // eventType alanı
      );
    }).toList();
  }

  // Katıldığım etkinlikleri çek
  Future<List<Event>> getAttendedEvents(String userId) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendedEvents')
            .get();

    return snap.docs.map((doc) {
      final d = doc.data();

      final joinedAt = d['joinedAt'];
      DateTime duration =
          joinedAt is Timestamp ? joinedAt.toDate() : DateTime.now();

      String location = '';
      if (d['eventLocation'] != null) {
        final loc = d['eventLocation'];
        if (loc is GeoPoint) {
          location = '${loc.latitude}, ${loc.longitude}';
        } else if (loc is String) {
          location = loc;
        }
      }

      return Event(
        eventId: d['eventId'] ?? '',
        title: d['eventTitle'] ?? '',
        location: location,
        description: '',
        gender: '',
        duration: duration,
        creatorId: '',
        eventType: d['eventType'] ?? '',
      );
    }).toList();
  }

  // Etkinliği sil
  Future<void> deleteEvent(String eventId) async {
    final firestore = FirebaseFirestore.instance;

    // 1. Etkinliğe ait tüm chat mesajlarını sil
    final messagesSnapshot =
        await firestore
            .collection('events')
            .doc(eventId)
            .collection('messages')
            .get();

    for (var msgDoc in messagesSnapshot.docs) {
      await msgDoc.reference.delete();
    }

    // 2. Etkinliğe ait katılım isteklerini sil
    final joinRequestsSnapshot =
        await firestore
            .collection('events')
            .doc(eventId)
            .collection('joinRequests')
            .get();

    for (var reqDoc in joinRequestsSnapshot.docs) {
      await reqDoc.reference.delete();
    }

    // 3. Etkinliğe ait katılımcıları sil
    final attendeesSnapshot =
        await firestore
            .collection('events')
            .doc(eventId)
            .collection('attendees')
            .get();

    for (var attendeeDoc in attendeesSnapshot.docs) {
      await attendeeDoc.reference.delete();
    }

    // 4. Etkinliği sil
    await firestore.collection('events').doc(eventId).delete();

    // 5. Tüm kullanıcılar üzerinde döngü yap ve katıldıklarım ile bildirimleri sil
    final usersSnapshot = await firestore.collection('users').get();

    for (var userDoc in usersSnapshot.docs) {
      // Katıldıklarım sil
      final attendedEventsRef = userDoc.reference.collection('attendedEvents');
      final attendedEventsSnapshot =
          await attendedEventsRef.where('eventId', isEqualTo: eventId).get();

      for (var doc in attendedEventsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Bildirimler sil
      final notificationsRef = userDoc.reference.collection('notifications');
      final notificationsSnapshot =
          await notificationsRef.where('eventId', isEqualTo: eventId).get();

      for (var notifDoc in notificationsSnapshot.docs) {
        await notifDoc.reference.delete();
      }
    }
  }
}

class Event {
  final String eventId;
  final String title;
  final String location;
  final String description;
  final String gender;
  final DateTime duration;
  final String creatorId;
  final String eventType;  // Yeni alan

  Event({
    required this.eventId,
    required this.title,
    required this.location,
    required this.description,
    required this.gender,
    required this.duration,
    required this.creatorId,
    required this.eventType,  // Yeni alan
  });
}

// Yardımcı fonksiyonlar
IconData getIconForCategory(String type) {
  switch (type.toLowerCase()) {
    case 'spor':
      return Icons.fitness_center;
    case 'sosyal':
      return Icons.group;
    case 'eğitim':
      return Icons.school;
    case 'kitap':
      return Icons.book;
    case 'eğlence':
      return Icons.celebration;
    default:
      return Icons.event;
  }
}

Color getColorForCategory(String type) {
  switch (type.toLowerCase()) {
    case 'spor':
      return Colors.green.shade50;
    case 'sosyal':
      return Colors.blue.shade50;
    case 'eğitim':
      return Colors.indigo.shade50;
    case 'kitap':
      return Colors.brown.shade50;
    case 'eğlence':
      return Colors.pink.shade50;
    default:
      return Colors.grey.shade200;
  }
}

class MyEventsPage extends StatefulWidget {
  final String userId;
  const MyEventsPage({super.key, required this.userId});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late EventService _eventService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _eventService = EventService();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<List<Event>> _getCreatedEvents() async =>
      _eventService.getCreatedEvents(widget.userId);

  Future<List<Event>> _getAttendedEvents() async =>
      _eventService.getAttendedEvents(widget.userId);

  Widget _eventTile(Event e, {required bool canDelete}) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    final bgColor = getColorForCategory(e.eventType);
    final icon = getIconForCategory(e.eventType);

    return Card(
      color: bgColor,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.deepPurple),
        title: Text(
          e.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(e.location),
            Text(dateFormat.format(e.duration)),
          ],
        ),
        trailing: canDelete
            ? IconButton(
                icon: Container(                    
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      Icons.delete,
                      color: Colors.grey[800],
                      size: 22,
                    ),
                  ),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Etkinliği sil"),
                      content: const Text("Bu etkinliği silmek istediğinize emin misiniz?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("İptal"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Sil"),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await _eventService.deleteEvent(e.eventId);
                    setState(() {}); // listeyi yenile
                  }
                },
              )
            : null,
        onTap: () {
          if (e.eventId.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Etkinlik bilgisi bulunamadı")),
            );
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(eventName: e.title, eventId: e.eventId),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6F2DBD);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Etkinliklerim",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [ 
            Tab(text: "Oluşturduklarım"),
            Tab(text: "Katıldıklarım"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
        FutureBuilder<List<Event>>(
        future: _getCreatedEvents(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
        }
                  if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('Oluşturduğun etkinlik bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) => _eventTile(events[index], canDelete: true),
          );
        },
      ),
      FutureBuilder<List<Event>>(
        future: _getAttendedEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return const Center(child: Text('Katıldığın etkinlik bulunmamaktadır.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) => _eventTile(events[index], canDelete: false),
          );
        },
      ),
    ],
  ),
);
}
}
          
