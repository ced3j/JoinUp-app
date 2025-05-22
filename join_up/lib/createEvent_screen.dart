import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:join_up/location_pick_screen.dart'; // Harita sayfasını import et
import 'package:join_up/home_screen.dart';

class CreateEventPage extends StatefulWidget {
  final String userId;
  const CreateEventPage({super.key, required this.userId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedGender = 'Herkes';
  DateTime? _selectedDate;
  bool _isLoading = false;

  LatLng? _selectedLocation; // Haritadan seçilen konum

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir tarih seçin')));
      return;
    }

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Lütfen bir konum seçin')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _firestore.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'gender': _selectedGender,
        'duration': _selectedDate!.toIso8601String(),
        'creatorId': widget.userId,
        'createdAt': FieldValue.serverTimestamp(),
        'location': GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
      });

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_titleController.text}" etkinliği oluşturuldu'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    setState(() {
      _selectedGender = 'Herkes';
      _selectedDate = null;
      _selectedLocation = null;
      _titleController.clear();
      _descriptionController.clear();
      _locationController.clear();
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6F2DBD);
    const darkColor = Color(0xFF0E1116);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Etkinlik Oluştur',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomePage()),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Etkinlik Bilgilerini Girin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Etkinliğinizin detaylarını aşağıda belirtin.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Başlık
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik Başlığı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),

              // Harita Konum Seçici
              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(
                  _selectedLocation == null
                      ? 'Konum Seç'
                      : 'Konum: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                ),
                onPressed: () async {
                  final picked = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LocationPickerPage(),
                    ),
                  );

                  if (picked != null && picked is LatLng) {
                    setState(() {
                      _selectedLocation = picked;
                      _locationController.text =
                          '${picked.latitude.toStringAsFixed(5)}, ${picked.longitude.toStringAsFixed(5)}';
                    });
                  }
                },
              ),
              const SizedBox(height: 8),

              // Konumu metin olarak göster (gizli)
              Offstage(
                offstage: true,
                child: TextFormField(
                  controller: _locationController,
                  validator:
                      (value) => value!.isEmpty ? 'Konum seçilmedi' : null,
                ),
              ),
              const SizedBox(height: 16),

              // Açıklama
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator:
                    (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),

              // Cinsiyet
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(
                  labelText: 'Katılımcı Cinsiyeti',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.people),
                ),
                items:
                    ['Herkes', 'Erkek', 'Kadın']
                        .map(
                          (gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 16),

              // Tarih seçici
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Süresi (Son Tarih)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _selectedDate == null
                        ? 'Tarih seçin'
                        : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Paylaş butonu
              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'Etkinliği Paylaş',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
