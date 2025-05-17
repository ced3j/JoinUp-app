import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  final String eventName;
  final String eventId; // <- bunu ekle

  const ChatScreen({
    super.key,
    required this.eventName,
    required this.eventId, // <- bunu ekle
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF6F2DBD),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(eventName, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: const [
                // Karşı tarafın mesajı
                Align(
                  alignment: Alignment.centerLeft,
                  child: ChatBubble(
                    message: "Selam! Katılmak ister misin?",
                    isMe: false,
                  ),
                ),
                SizedBox(height: 10),
                // Kullanıcının mesajı
                Align(
                  alignment: Alignment.centerRight,
                  child: ChatBubble(message: "Evet çok isterim!", isMe: true),
                ),
              ],
            ),
          ),
          const MessageInput(),
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

class MessageInput extends StatelessWidget {
  const MessageInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: Colors.grey[200],
      child: Row(
        children: [
          Expanded(
            child: TextField(
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
              onPressed: () {
                // Mesaj gönderme işlemi burada yapılacak
              },
            ),
          ),
        ],
      ),
    );
  }
}
