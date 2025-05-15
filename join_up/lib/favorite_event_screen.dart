import 'package:flutter/material.dart';

class FavoritesPage extends StatefulWidget {
  final Set<String> favorites; // favori etkinliklerin id'lerini tutuyoruz
  final Function(String) toggleFavori; // eventId parametresini alacak

  const FavoritesPage({
    super.key,
    required this.favorites,
    required this.toggleFavori,
  });

  @override
  _FavorilerSayfasiState createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD); // Mor ton

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Favori Etkinlikler',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      body: ListView(
        children:
            widget.favorites.map((eventId) {
              return Card(
                child: ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text("Etkinlik Başlığı $eventId"),
                  subtitle: Text("Açıklama $eventId"),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.red),
                    onPressed: () {
                      widget.toggleFavori(eventId); // Favoriden çıkar
                      setState(() {});
                    },
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
