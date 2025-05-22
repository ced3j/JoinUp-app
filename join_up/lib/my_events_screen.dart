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
      return Event(
        eventId: doc.id, // 👈 id
        title: data['title'],
        location: data['location'],
        description: data['description'],
        gender: data['gender'],
        duration: DateTime.parse(data['duration']),
        creatorId: data['creatorId'],
      );
    }).toList();
  }

  // Katıldığım etkinlikleri çek
  Future<List<Event>> getAttendedEvents(String userId) async {
    final snap =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('attendedEvents') // docs’un id’si = eventId
            .get();

    return snap.docs.map((doc) {
      final d = doc.data();
      return Event(
        eventId: doc.id, // 👈 id burada
        title: d['eventTitle'],
        location: d['eventLocation'],
        description: '',
        gender: '',
        duration: d['joinedAt'].toDate(),
        creatorId: '',
      );
    }).toList();
  }
}

class Event {
  final String eventId; // 👈 yeni alan
  final String title;
  final String location;
  final String description;
  final String gender;
  final DateTime duration;
  final String creatorId;

  Event({
    required this.eventId,
    required this.title,
    required this.location,
    required this.description,
    required this.gender,
    required this.duration,
    required this.creatorId,
  });
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

  // 👇 ortak kart widget’ı
  Widget _eventTile(Event e) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');
    return ListTile(
      title: Text(e.title),
      subtitle: Text(e.location),
      trailing: Text(dateFormat.format(e.duration)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ChatScreen(
                  eventName: e.title,
                  eventId: e.eventId, // sohbet ekranına id ve isim gönder
                ),
          ),
        );
      },
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white, // Seçili tab metin rengi
          unselectedLabelColor: Colors.white, // Seçili olmayan tab metin rengi
          tabs: const [
            Tab(text: "Oluşturduklarım"),
            Tab(text: "Katıldıklarım"),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 1) Oluşturduğum etkinlikler
          FutureBuilder<List<Event>>(
            future: _getCreatedEvents(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return const Center(
                  child: Text("Henüz etkinlik oluşturmadınız."),
                );
              }
              return ListView(children: list.map(_eventTile).toList());
            },
          ),
          // 2) Katıldığım etkinlikler
          FutureBuilder<List<Event>>(
            future: _getAttendedEvents(),
            builder: (context, snap) {
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = snap.data!;
              if (list.isEmpty) {
                return const Center(
                  child: Text("Henüz katıldığınız etkinlik yok."),
                );
              }
              return ListView(children: list.map(_eventTile).toList());
            },
          ),
        ],
      ),
    );
  }
}
