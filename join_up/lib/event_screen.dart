import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ChatScreen extends StatefulWidget {
  final String eventName;
  final String eventId;

  const ChatScreen({super.key, required this.eventName, required this.eventId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _showDetails = false;

  void _toggleDetailsPanel() {
    setState(() {
      _showDetails = !_showDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F2DBD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.eventName,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: Color.fromARGB(220, 255, 235, 58), // Sarımsı renk
            ),
            onPressed: _toggleDetailsPanel,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: ChatMessages(eventId: widget.eventId)),
              MessageInput(eventId: widget.eventId),
            ],
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: _showDetails ? 0 : -300,
            left: 0,
            right: 0,
            height: 300,
            child: Material(
              elevation: 8,
              child: EventDetailsPanel(
                eventId: widget.eventId,
                onClose: _toggleDetailsPanel,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessages extends StatefulWidget {
  final String eventId;

  const ChatMessages({super.key, required this.eventId});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final Map<String, String> _userNamesCache = {};

  Future<String> _getUserName(String userId) async {
    if (_userNamesCache.containsKey(userId)) {
      return _userNamesCache[userId]!;
    }

    final doc =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    final userName = doc.data()?['fullName'] ?? 'Bilinmeyen';
    _userNamesCache[userId] = userName;
    return userName;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance
              .collection('chats')
              .doc(widget.eventId)
              .collection('messages')
              .orderBy('createdAt', descending: true)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final chatDocs = snapshot.data!.docs;

        return ListView.builder(
          reverse: true,
          itemCount: chatDocs.length,
          itemBuilder: (ctx, index) {
            final data = chatDocs[index];
            final userId = data['userId'];
            final currentUserId = FirebaseAuth.instance.currentUser!.uid;
            final isMe = userId == currentUserId;

            return FutureBuilder<String>(
              future: _getUserName(userId),
              builder: (context, userSnapshot) {
                final userName = userSnapshot.data ?? '...';
                return Align(
                  alignment:
                      isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: ChatBubble(
                    message: data['text'],
                    isMe: isMe,
                    userName: userName,
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final String userName;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isMe,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 8,
        left: isMe ? 60 : 10,
        right: isMe ? 10 : 60,
      ),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF6F2DBD) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                userName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.black87,
                ),
              ),
            ),
          Text(
            message,
            style: TextStyle(
              color: isMe ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class MessageInput extends StatefulWidget {
  final String eventId;

  const MessageInput({super.key, required this.eventId});

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  final _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.eventId)
        .collection('messages')
        .add({
          'text': text,
          'createdAt': Timestamp.now(),
          'userId': FirebaseAuth.instance.currentUser!.uid,
        });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Mesaj yaz...",
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: const Color(0xFF6F2DBD),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}

class EventDetailsPanel extends StatelessWidget {
  final String eventId;
  final VoidCallback onClose;

  const EventDetailsPanel({
    super.key,
    required this.eventId,
    required this.onClose,
  });

  void _openMap(double lat, double lng) async {
    final uri = Uri.parse(
      "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('events').doc(eventId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final participantsData = data['currentParticipants'];
          int currentParticipants = 0;

          if (participantsData is List) {
            currentParticipants = participantsData.length;
          } else if (participantsData is int) {
            currentParticipants = participantsData;
          }

          final gender = data['gender'] ?? 'Herkes';
          final GeoPoint location = data['location'];

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ),
              Text(
                "Katılımcı Sayısı: $currentParticipants",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Cinsiyet Kriteri: $gender",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(location.latitude, location.longitude),
                    zoom: 14,
                  ),
                  markers: {
                    Marker(
                      markerId: const MarkerId("eventLocation"),
                      position: LatLng(location.latitude, location.longitude),
                      onTap:
                          () => _openMap(location.latitude, location.longitude),
                    ),
                  },
                  zoomControlsEnabled: false,
                  onTap: (LatLng pos) => _openMap(pos.latitude, pos.longitude),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
