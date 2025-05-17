import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatScreen extends StatelessWidget {
  final String eventName;
  final String eventId;

  const ChatScreen({super.key, required this.eventName, required this.eventId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F2DBD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(eventName, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream:
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(eventId)
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
                  itemBuilder:
                      (ctx, index) => Align(
                        alignment:
                            chatDocs[index]['userId'] ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: ChatBubble(
                          message: chatDocs[index]['text'],
                          isMe:
                              chatDocs[index]['userId'] ==
                              FirebaseAuth.instance.currentUser!.uid,
                        ),
                      ),
                );
              },
            ),
          ),
          MessageInput(eventId: eventId),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      margin: EdgeInsets.only(left: isMe ? 60 : 10, right: isMe ? 10 : 60),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF6F2DBD) : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: isMe ? Colors.white : Colors.black87,
          fontSize: 16,
        ),
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
