import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcıya ait oluşturduğu etkinlikleri çekme
  Future<List<Event>> getCreatedEvents(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('events')
              .where('creatorId', isEqualTo: userId)
              .get();

      return snapshot.docs
          .map(
            (doc) => Event(
              title: doc['title'],
              location: doc['location'],
              description: doc['description'],
              gender: doc['gender'],
              duration: DateTime.parse(doc['duration']),
              creatorId: doc['creatorId'],
            ),
          )
          .toList();
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }

  // Kullanıcının katıldığı etkinlikleri çekme
  Future<List<Event>> getAttendedEvents(String userId) async {
    try {
      final snapshot =
          await _firestore
              .collection('users')
              .doc(userId)
              .collection('attendedEvents') // Katıldıkları etkinlikler
              .get();

      return snapshot.docs
          .map(
            (doc) => Event(
              title: doc['eventTitle'],
              location: doc['eventLocation'],
              description:
                  '', // Eğer açıklama gerekiyorsa buraya ekleyebilirsin
              gender: '', // Gereksizse boş bırakabilirsin
              duration: DateTime.parse(doc['joinedAt'].toDate().toString()),
              creatorId: '', // Burada etkinlik sahibi bilgisi gerekmez
            ),
          )
          .toList();
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }
}

class Event {
  final String title;
  final String location;
  final String description;
  final String gender;
  final DateTime duration;
  final String creatorId;

  Event({
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

  // Etkinlik oluşturduğunda çekilen etkinlikler
  Future<List<Event>> _getCreatedEvents() async {
    return await _eventService.getCreatedEvents(widget.userId);
  }

  // Katıldığın etkinlikleri çekme
  Future<List<Event>> _getAttendedEvents() async {
    return await _eventService.getAttendedEvents(widget.userId);
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
          indicatorWeight: 3.0,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white,
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
          // Oluşturulan etkinlikler
          FutureBuilder<List<Event>>(
            future: _getCreatedEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Bir hata oluştu"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Henüz etkinlik oluşturmadınız."),
                );
              }

              final events = snapshot.data!;
              final dateFormat = DateFormat("dd.MM.yyyy HH:mm");

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.location),
                    trailing: Text(dateFormat.format(event.duration)),
                    onTap: () {
                      // Etkinlik detayına gitmek istersen burada yönlendirme yapılabilir
                    },
                  );
                },
              );
            },
          ),
          // Katıldığın etkinlikler
          FutureBuilder<List<Event>>(
            future: _getAttendedEvents(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return const Center(child: Text("Bir hata oluştu"));
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text("Henüz katıldığınız etkinlik yok."),
                );
              }

              final events = snapshot.data!;
              final dateFormat = DateFormat("dd.MM.yyyy HH:mm");

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  return ListTile(
                    title: Text(event.title),
                    subtitle: Text(event.location),
                    trailing: Text(dateFormat.format(event.duration)),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
