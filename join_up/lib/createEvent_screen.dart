import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:join_up/location_pick_screen.dart';
// Removed: import 'package:join_up/home_screen.dart'; // Not needed for Navigator.pop
import 'package:geocoding/geocoding.dart';

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
  final _minParticipantsController = TextEditingController();
  final _maxParticipantsController = TextEditingController();

  String _selectedGender = 'Herkes';
  DateTime? _selectedDate;
  bool _isLoading = false;

  LatLng? _selectedLocation;
  String? _selectedLocationName;

  String _selectedEventType = 'Diğer';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<String> _eventTypes = [
    'Spor',
    'Sosyal',
    'Eğitim',
    'Kitap',
    'Eğlence',
    'Diğer',
  ];

  Future<void> _getLocationName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: "tr_TR",
      );
      if (placemarks.isNotEmpty) {
        setState(() {
          _selectedLocationName = placemarks.first.administrativeArea;
          if (_selectedLocationName == null || _selectedLocationName!.isEmpty) {
            _selectedLocationName = placemarks.first.locality;
          }
          if (_selectedLocationName == null || _selectedLocationName!.isEmpty) {
            _selectedLocationName = 'Bilinmeyen Konum';
          }
        });
      } else {
        setState(() {
          _selectedLocationName = 'Konum adı bulunamadı';
        });
      }
    } catch (e) {
      print('Konum adı alınırken hata oluştu: $e');
      setState(() {
        _selectedLocationName = 'Hata: Konum adı alınamadı';
      });
    }
  }

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

    final int? minParticipants = int.tryParse(_minParticipantsController.text);
    final int? maxParticipants = int.tryParse(_maxParticipantsController.text);

    if (minParticipants == null || maxParticipants == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen geçerli kişi sayısı aralığı girin.'),
        ),
      );
      return;
    }
    if (minParticipants <= 0 || maxParticipants <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kişi sayıları pozitif olmalıdır.')),
      );
      return;
    }
    if (minParticipants > maxParticipants) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Minimum kişi sayısı, maksimum kişi sayısından küçük veya eşit olmalıdır.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _getLocationName(_selectedLocation!);

      await _firestore.collection('events').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'gender': _selectedGender,
        // CHANGED: Field name 'duration' to 'eventDate' for clarity
        'eventDate': _selectedDate!.toIso8601String(),
        'creatorId': widget.userId,
        'createdAt': FieldValue.serverTimestamp(),
        'location': GeoPoint(
          _selectedLocation!.latitude,
          _selectedLocation!.longitude,
        ),
        'locationName': _selectedLocationName,
        'minParticipants': minParticipants,
        'maxParticipants': maxParticipants,
        'eventType': _selectedEventType,
        'currentParticipants': 1, // Creator is the first participant
      });

      _resetForm();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${_titleController.text}" etkinliği oluşturuldu'),
        ),
      );
      // After successful creation, pop back to the previous screen (HomePage)
      if (mounted) {
        // Check if the widget is still in the tree
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Hata: ${e.toString()}')));
    } finally {
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() => _isLoading = false);
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    if (mounted) {
      setState(() {
        _selectedGender = 'Herkes';
        _selectedDate = null;
        _selectedLocation = null;
        _selectedLocationName = null;
        _titleController.clear();
        _descriptionController.clear();
        _minParticipantsController.clear();
        _maxParticipantsController.clear();
        _selectedEventType = 'Diğer';
      });
    }
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
    _minParticipantsController.dispose();
    _maxParticipantsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6F2DBD);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Etkinlik Oluştur',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
        // CHANGED: AppBar back button to pop the current screen
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
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
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Etkinliğinizin detaylarını aşağıda belirtin.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),

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

              ElevatedButton.icon(
                icon: const Icon(Icons.map),
                label: Text(
                  _selectedLocationName == null ||
                          _selectedLocationName!.isEmpty
                      ? (_selectedLocation == null
                          ? 'Konum Seç'
                          : 'Konum adı alınıyor...')
                      : 'Konum: $_selectedLocationName',
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
                      _selectedLocationName = 'Konum adı alınıyor...';
                    });
                    await _getLocationName(picked);
                  }
                },
              ),
              const SizedBox(height: 16),

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

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _minParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min. Katılımcı Sayısı',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people_alt),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Zorunlu';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _maxParticipantsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max. Katılımcı Sayısı',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.people),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Zorunlu';
                        }
                        if (int.tryParse(value) == null) {
                          return 'Geçerli sayı girin';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedEventType,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik Türü',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items:
                    _eventTypes
                        .map(
                          (type) =>
                              DropdownMenuItem(value: type, child: Text(type)),
                        )
                        .toList(),
                onChanged:
                    (value) => setState(() => _selectedEventType = value!),
              ),
              const SizedBox(height: 16),

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

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    // UPDATED: Label text for clarity
                    labelText: 'Etkinlik Tarihi',
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
