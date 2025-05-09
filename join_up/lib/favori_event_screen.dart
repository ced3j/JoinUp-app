import 'package:flutter/material.dart';


class FavorilerSayfasi extends StatefulWidget {
  final Set<int> favoriler;
  final Function(int) toggleFavori;

  const FavorilerSayfasi({
    super.key,
    required this.favoriler,
    required this.toggleFavori,
  });

  @override
  _FavorilerSayfasiState createState() => _FavorilerSayfasiState();
}

class _FavorilerSayfasiState extends State<FavorilerSayfasi> {
  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD); // Mor ton
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favori Etkinlikler', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
        ),
      body: ListView(
        children: widget.favoriler.map((index) {
          return Card(
            child: ListTile(
              leading: Icon(
                Icons.star,
                color: Colors.amber,
              ),
              title: Text("Etkinlik Başlığı $index"),
              subtitle: Text("Açıklama $index"),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  widget.toggleFavori(index); // ana sayfadaki favoriler güncelleniyor
                  setState(() {}); // bu sayfa da güncellensin
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
