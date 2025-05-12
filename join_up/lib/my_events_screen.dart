import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:join_up/createEvent_screen.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kullanıcıya ait etkinlikleri çekme
  Future<List<Event>> getCreatedEvents(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('events')
          .where('creatorId', isEqualTo: userId)
          .get();

      //print('Sorgu sonucunda bulunan etkinlik sayısı: ${snapshot.docs.length}');

      //if (snapshot.docs.isEmpty) {
        //print('Hiçbir etkinlik bulunamadı.');
      //}

      return snapshot.docs
          .map((doc) => Event(
                title: doc['title'],
                location: doc['location'],
                description: doc['description'],
                gender: doc['gender'],
                duration: DateTime.parse(doc['duration']),
                creatorId: doc['creatorId'],
              ))
          .toList();
    } catch (e) {
      print('Hata: $e');
      return [];
    }
  }
}

class MyEventsPage extends StatefulWidget {
  final String userId;

  const MyEventsPage({super.key, required this.userId});

  @override
  State<MyEventsPage> createState() => _MyEventsPageState();
}

class _MyEventsPageState extends State<MyEventsPage> with SingleTickerProviderStateMixin {
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

  Future<List<Event>> _getCreatedEvents() async {
    return await _eventService.getCreatedEvents(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6F2DBD);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Etkinliklerim", style: TextStyle(color: Colors.white)),
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
                return const Center(child: Text("Henüz etkinlik oluşturmadınız."));
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
          const Center(child: Text("Katıldığınız etkinlikler burada listelenecek.")),
        ],
      ),
    );
  }
}
