import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'event_screen.dart'; // sohbet ekranını import et

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // -------------------- OLUŞTURDUKLARIM --------------------
  Future<List<Event>> getCreatedEvents(String userId) async {
    final snap =
        await _firestore
            .collection('events')
            .where('creatorId', isEqualTo: userId)
            .get();

    return snap.docs.map((doc) {
      final data = doc.data();
      return _eventFromDoc(doc.id, data);
    }).toList();
  }

  // -------------------- KATILDIKLARIM (düzeltilmiş) --------
  Future<List<Event>> getAttendedEvents(String userId) async {
    // 1) attendedEvents koleksiyonunda sadece eventId (veya docId) var
    final attendedSnap =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendedEvents')
            .get();

    // 2) Her eventId için gerçek etkinlik belgesini (events) çek
    final List<Event> attendedEvents = [];
    for (final doc in attendedSnap.docs) {
      // eventId ya alanda ya da doc.id’de olabilir
      final eventId = doc.data()['eventId'] ?? doc.id;

      if (eventId == null) continue;

      final eventDoc = await _firestore.collection('events').doc(eventId).get();

      if (!eventDoc.exists) continue;

      attendedEvents.add(_eventFromDoc(eventId, eventDoc.data()!));
    }
    return attendedEvents;
  }

  // ---------------------------------------------------------
  // Ortak: Firestore verisini Event modeline dönüştür
  Event _eventFromDoc(String id, Map<String, dynamic> data) {
    // duration alanı
DateTime createdAt;
    final rawCreatedAt = data['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt) ?? DateTime(2000);
    } else {
      createdAt = DateTime(2000); // fallback
    }

    // locationName
    String locationText = 'Konum Bilgisi Yok';
    if (data['locationName'] != null &&
        data['locationName'].toString().trim().isNotEmpty) {
      locationText = data['locationName'];
    }

    return Event(
      eventId: id,
      title: data['title'] ?? '',
      location: locationText,
      description: data['description'] ?? '',
      gender: data['gender'] ?? '',
      creatorId: data['creatorId'] ?? '',
      eventType: data['eventType'] ?? '',
      minParticipants: data['minParticipants'] ?? 0,
      maxParticipants: data['maxParticipants'] ?? 0,
      currentParticipants: data['currentParticipants'] ?? 0,
      createdAt: createdAt, // 🔥 BURASI EKLENDİ
    );

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
  final String creatorId;
  final String eventType;
  final int minParticipants; // Yeni eklendi
  final int maxParticipants; // Yeni eklendi
  final int currentParticipants; // Yeni eklendi
  final DateTime createdAt; 

  Event({
    required this.eventId,
    required this.title,
    required this.location,
    required this.description,
    required this.gender,
    required this.creatorId,
    required this.eventType,
    required this.minParticipants,
    required this.maxParticipants,
    required this.currentParticipants,
    required this.createdAt,
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.deepPurple),
        title: Text(
          e.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.location,
            ), // Artık sadece locationName'den veya eventLocationName'den gelen değer burada
            Text(dateFormat.format(e.createdAt)),
          ],
        ),
        trailing:
            canDelete
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
                      builder:
                          (context) => AlertDialog(
                            title: const Text("Etkinliği sil"),
                            content: const Text(
                              "Bu etkinliği silmek istediğinize emin misiniz? Bu işlem geri alınamaz.",
                            ),
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
                      // Kullanıcıya bilgi ver
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Etkinlik başarıyla silindi.'),
                        ),
                      );
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
              builder:
                  (_) => ChatScreen(eventName: e.title, eventId: e.eventId),
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
                return const Center(
                  child: Text('Oluşturduğun etkinlik bulunmamaktadır.'),
                );
              }

              return ListView.builder(
                itemCount: events.length,
                itemBuilder:
                    (context, index) =>
                        _eventTile(events[index], canDelete: true),
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
                return const Center(
                  child: Text('Katıldığın etkinlik bulunmamaktadır.'),
                );
              }

              return ListView.builder(
                itemCount: events.length,
                itemBuilder:
                    (context, index) =>
                        _eventTile(events[index], canDelete: false),
              );
            },
          ),
        ],
      ),
    );
  }
}
