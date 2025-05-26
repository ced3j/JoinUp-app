// home_screen.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For DateFormat
import 'package:join_up/Notifications_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:join_up/favorite_event_screen.dart';
import 'package:join_up/createEvent_screen.dart';
import 'package:join_up/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:join_up/filter_screen.dart'; // Assuming this import is correct
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchController = TextEditingController();
  final Set<String> favoriEvents = {};
  bool hasNotifications = false;

  // New filter state variables
  String? _selectedCategoryFilter;
  DateTime? _selectedDateFilter;
  int _attendeesMinFilter = 1;
  int _attendeesMaxFilter = 100;
  String _selectedGenderFilter = 'Herkes';

  @override
  void initState() {
    super.initState();
    _loadFavoritesFromFirestore();
    checkNotifications();
  }

  void checkNotifications() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final querySnapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .where('read', isEqualTo: false)
            .limit(1)
            .get();

    setState(() {
      hasNotifications = querySnapshot.docs.isNotEmpty;
    });
  }

  Color getCardColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'spor':
        return Colors.green[50]!;
      case 'sosyal':
        return Colors.blue[50]!;
      case 'eğitim':
        return Colors.orange[50]!;
      case 'kitap':
        return Colors.purple[50]!;
      case 'eğlence':
        return Colors.pink[50]!;
      default:
        return Colors.grey[50]!;
    }
  }

  IconData getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'spor':
        return LucideIcons.dumbbell;
      case 'sosyal':
        return LucideIcons.users;
      case 'eğitim':
        return LucideIcons.graduationCap;
      case 'kitap':
        return LucideIcons.bookOpen;
      case 'eğlence':
        return LucideIcons.partyPopper;
      default:
        return LucideIcons.calendarHeart;
    }
  }

  Future<void> _loadFavoritesFromFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .collection('favorites')
              .get();

      if (mounted) {
        setState(() {
          favoriEvents.clear();
          favoriEvents.addAll(snapshot.docs.map((doc) => doc.id));
        });
      }
    } catch (e) {
      print("Error loading favorites: $e");
    }
  }

  Future<void> toggleFavori(String eventId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final favRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('favorites')
        .doc(eventId);

    try {
      final doc = await favRef.get();

      if (doc.exists) {
        await favRef.delete();
        if (mounted) {
          setState(() {
            favoriEvents.remove(eventId);
          });
        }
      } else {
        await favRef.set({'timestamp': FieldValue.serverTimestamp()});
        if (mounted) {
          setState(() {
            favoriEvents.add(eventId);
          });
        }
      }
    } catch (e) {
      print("Error toggling favorite: $e");
    }
  }

  void showJoinRequestSheet(
    BuildContext context,
    String eventId,
    String eventTitle,
    String creatorId,
    int currentParticipants,
    int maxParticipants,
    String description,
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
            height: MediaQuery.of(context).size.height * 0.65,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
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
                Text(
                  "Katılım için etkinlik sahibinin onaylaması gerekiyor.\n",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                
                Text(
                  description,
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),

                const SizedBox(height: 8),
                Text(
                  "Mevcut Katılımcı: $currentParticipants/$maxParticipants",
                  style: const TextStyle(fontSize: 15),
                ),
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
                          currentUserId == creatorId ||
                                  (maxParticipants > 0 &&
                                      currentParticipants >= maxParticipants)
                              ? null
                              : () async {
                                try {
                                  final joinRequestRef = FirebaseFirestore
                                      .instance
                                      .collection('events')
                                      .doc(eventId)
                                      .collection('joinRequests');

                                  final existingRequest =
                                      await joinRequestRef
                                          .where(
                                            'userId',
                                            isEqualTo: currentUserId,
                                          )
                                          .limit(1)
                                          .get();

                                  if (existingRequest.docs.isNotEmpty) {
                                    if (!context.mounted) return;
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder:
                                          (context) => AlertDialog(
                                            title: const Text("Uyarı"),
                                            content: const Text(
                                              "Bu etkinliğe daha önce istek gönderdiniz veya zaten katılımcısınız.",
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed:
                                                    () =>
                                                        Navigator.pop(context),
                                                child: const Text("Tamam"),
                                              ),
                                            ],
                                          ),
                                    );
                                    return;
                                  }

                                  await joinRequestRef.add({
                                    'userId': currentUserId,
                                    'status': 'pending',
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(creatorId)
                                      .collection('notifications')
                                      .add({
                                        'type': 'join_request',
                                        'message':
                                            '${FirebaseAuth.instance.currentUser?.displayName ?? 'Bir kullanıcı'} "${eventTitle}" etkinliğinize katılmak için istek gönderdi.',
                                        'eventId': eventId,
                                        'eventTitle': eventTitle,
                                        'senderId': currentUserId,
                                        'requestId': joinRequestRef.doc().id,
                                        'timestamp':
                                            FieldValue.serverTimestamp(),
                                        'read': false,
                                      });

                                  if (!context.mounted) return;
                                  Navigator.pop(context);

                                  showDialog(
                                    context: context,
                                    builder:
                                        (context) => AlertDialog(
                                          title: const Text("Başarılı"),
                                          content: const Text(
                                            "Katılım isteğiniz gönderildi. Etkinlik sahibi onayladığında haberdar edileceksiniz.",
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
                                } catch (e) {
                                  print("Error sending join request: $e");
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    showCustomSnackBar(
                                      context,
                                      "İstek gönderilirken bir hata oluştu: ${e.toString()}",
                                      2,
                                    );
                                  }
                                }
                              },
                      child: const Text("İstek Gönder"), //
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
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Ana Sayfa',
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, size: 25),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => FavoritesPage(
                        favorites: favoriEvents,
                        toggleFavori: toggleFavori,
                      ),
                ),
              ).then((_) {
                _loadFavoritesFromFirestore();
              });
            },
          ),
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(Icons.notifications, size: 25),
                if (hasNotifications)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 11,
                      height: 11,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
              await Future.delayed(Duration(milliseconds: 500));
              checkNotifications();
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
                Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: IconButton(
                    onPressed: () async {
                      // Pass current filter values to FilterScreen
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FilterScreen(
                                onApplyFilters: (filters) {
                                  // This callback is triggered when "Apply" button is pressed in FilterScreen
                                  setState(() {
                                    _selectedCategoryFilter =
                                        filters['category'];
                                    _selectedDateFilter = filters['date'];
                                    _attendeesMinFilter =
                                        filters['attendeesMin'];
                                    _attendeesMaxFilter =
                                        filters['attendeesMax'];
                                    _selectedGenderFilter = filters['gender'];
                                  });
                                },
                              ),
                        ),
                      );
                      // If the user navigates back without applying filters, nothing happens.
                      // If applied, the onApplyFilters callback above handles the state update.
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
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: "Etkinlik Ara...",
                      hintStyle: TextStyle(
                        color: Colors.black.withOpacity(0.5),
                      ),
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
                      if (mounted) setState(() {});
                    },
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(left: 8.0),
                  child: IconButton(
                    onPressed: () {
                      print('Arama butonu tıklandı: ${searchController.text}');
                      // No need to call setState here as onChanged already does it
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
                  FirebaseFirestore.instance
                      .collection('events')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text("Bir hata oluştu: ${snapshot.error}"),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("Gösterilecek etkinlik bulunamadı."),
                  );
                }

                var events = snapshot.data!.docs;
                final searchText = searchController.text.toLowerCase();

                // Apply search filter first
                if (searchText.isNotEmpty) {
                  events =
                      events.where((event) {
                        final Map<String, dynamic>? data =
                            event.data() as Map<String, dynamic>?;
                        final title =
                            (data?['title'] as String? ?? '').toLowerCase();
                        return title.contains(searchText);
                      }).toList();
                }

                // Apply category filter
                if (_selectedCategoryFilter != null &&
                    _selectedCategoryFilter != 'Tümü') {
                  // Assuming 'Tümü' or similar implies no filter
                  events =
                      events.where((event) {
                        final Map<String, dynamic>? data =
                            event.data() as Map<String, dynamic>?;
                        final eventType =
                            (data?['eventType'] as String? ?? '').toLowerCase();
                        return eventType ==
                            _selectedCategoryFilter!.toLowerCase();
                      }).toList();
                }

                // Apply date filter
                if (_selectedDateFilter != null) {
                  events =
                      events.where((event) {
                        final Map<String, dynamic>? data =
                            event.data() as Map<String, dynamic>?;
                        final eventDateString = data?['eventDate'] as String?;
                        if (eventDateString == null ||
                            eventDateString.isEmpty) {
                          return false;
                        }
                        try {
                          final eventDate = DateTime.parse(eventDateString);
                          // Compare only dates, ignore time
                          return eventDate.year == _selectedDateFilter!.year &&
                              eventDate.month == _selectedDateFilter!.month &&
                              eventDate.day == _selectedDateFilter!.day;
                        } catch (e) {
                          print("Error parsing date for filter: $e");
                          return false;
                        }
                      }).toList();
                }

                // Apply attendees filter
                events =
                    events.where((event) {
                      final Map<String, dynamic>? data =
                          event.data() as Map<String, dynamic>?;
                      final maxParticipants =
                          (data?['maxParticipants'] as num?)?.toInt() ?? 0;
                      // If maxParticipants is 0, it means unlimited, so it always passes the filter
                      if (maxParticipants == 0) return true;

                      return maxParticipants >= _attendeesMinFilter &&
                          maxParticipants <= _attendeesMaxFilter;
                    }).toList();

                // Apply gender filter (assuming 'gender' field exists in event data)
                if (_selectedGenderFilter != 'Herkes') {
                  events =
                      events.where((event) {
                        final Map<String, dynamic>? data =
                            event.data() as Map<String, dynamic>?;
                        final requiredGender =
                            (data?['requiredGender'] as String? ?? '')
                                .toLowerCase();
                        return requiredGender ==
                                _selectedGenderFilter.toLowerCase() ||
                            requiredGender ==
                                'herkes'; // If event is for 'Herkes', it passes
                      }).toList();
                }

                if (events.isEmpty && searchText.isNotEmpty) {
                  return Center(
                    child: Text(
                      "Aramanızla eşleşen etkinlik bulunamadı: \"$searchText\"",
                    ),
                  );
                } else if (events.isEmpty &&
                    searchText.isEmpty &&
                    (_selectedCategoryFilter != null ||
                        _selectedDateFilter != null ||
                        _attendeesMinFilter != 1 ||
                        _attendeesMaxFilter != 100 ||
                        _selectedGenderFilter != 'Herkes')) {
                  return const Center(
                    child: Text(
                      "Seçilen filtrelere uygun etkinlik bulunamadı.",
                    ),
                  );
                } else if (events.isEmpty) {
                  return const Center(
                    child: Text("Gösterilecek etkinlik bulunamadı."),
                  );
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    var event = events[index];
                    var eventId = event.id;

                    final Map<String, dynamic>? data =
                        event.data() as Map<String, dynamic>?;

                    final String eventTitle =
                        data?['title'] as String? ?? 'Başlık Yok';
                    final String creatorId =
                        data?['creatorId'] as String? ?? '';
                    bool favorideMi = favoriEvents.contains(eventId);

                    final int maxParticipants =
                        (data?['maxParticipants'] as num?)?.toInt() ?? 0;
                    final int currentParticipants =
                        (data?['currentParticipants'] as num?)?.toInt() ?? 0;

                    final String eventType =
                        data?['eventType'] as String? ?? 'Diğer';
                    final String eventDateString =
                        data?['eventDate'] as String? ?? '';
                    final String description = data?['description'] as String? ?? 'Açıklama yok';

                    
                    
                    String formattedDate = 'Tarih Belirtilmemiş';
                    if (eventDateString.isNotEmpty) {
                      try {
                        formattedDate = DateFormat(
                          'dd/MM/yyyy',
                        ).format(DateTime.parse(eventDateString));
                      } catch (e) {
                        print(
                          "Date parsing error for event $eventId (date: '$eventDateString'): $e",
                        );
                      }
                    }

                    String locationText = 'Konum Bilgisi Yok';
                    final String? locationName =
                        data?['locationName'] as String?;
                    final GeoPoint? locationGeoPoint =
                        data?['location'] as GeoPoint?;

                    if (locationName != null && locationName.isNotEmpty) {
                      locationText = locationName;
                    } else if (locationGeoPoint != null) {
                      locationText =
                          'Enlem: ${locationGeoPoint.latitude.toStringAsFixed(2)}, Boylam: ${locationGeoPoint.longitude.toStringAsFixed(2)}';
                    }

                    return Card(
                      color: getCardColor(eventType),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      elevation: 2.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12.0),
                        leading: Icon(
                          getEventIcon(eventType),
                          color: primaryColor,
                          size: 30,
                        ),
                        title: Text(
                          eventTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tarih: $formattedDate',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Konum: $locationText',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Tür: $eventType',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              Text(
                                'Katılımcılar: $currentParticipants / $maxParticipants',
                                style: TextStyle(
                                  color:
                                      (maxParticipants > 0 &&
                                              currentParticipants >=
                                                  maxParticipants)
                                          ? Colors.red
                                          : Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            favorideMi
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: favorideMi ? Colors.amber[600] : Colors.grey,
                            size: 28,
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
                            currentParticipants,
                            maxParticipants,
                            description,
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
          if (index == 0 && ModalRoute.of(context)?.settings.name == '/') {
            return;
          }
          switch (index) {
            case 0:
              if (ModalRoute.of(context)?.settings.name != '/') {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (Route<dynamic> route) => false,
                );
              }
              break;
            case 1:
              final currentUser = FirebaseAuth.instance.currentUser;
              if (currentUser != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => CreateEventPage(userId: currentUser.uid),
                  ),
                );
              } else {
                showCustomSnackBar(
                  context,
                  "Etkinlik oluşturmak için giriş yapmalısınız.",
                  2,
                );
              }
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Ana Sayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.add_rounded,
              size: 25.0,
              color: Color.fromARGB(255, 46, 3, 54),
            ),
            label: 'Etkinlik Oluştur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Profil',
          ),
        ],
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 8.0,
      ),
    );
  }
}