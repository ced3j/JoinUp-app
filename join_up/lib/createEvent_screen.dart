import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

// Event model to store event data
class Event {
  final String title;
  final String location;
  final String description;
  final String gender;
  final DateTime duration; // End date/time for the event
  final String creatorId; // User ID of the creator

  Event({
    required this.title,
    required this.location,
    required this.description,
    required this.gender,
    required this.duration,
    required this.creatorId,
  });
}

// Abstract interface for event service
abstract class EventServiceInterface {
  Future<bool> createEvent(Event event);
}

// Concrete implementation of event service
class EventService implements EventServiceInterface {
  @override
  Future<bool> createEvent(Event event) async {
    try {
      // Simulate API call to save event
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Event created: ${event.title}');
      return true; // Assume success
    } catch (e) {
      debugPrint('Error creating event: $e');
      return false;
    }
  }
}

// CreateEventPage widget
class CreateEventPage extends StatefulWidget {
  final String userId; // Current user's ID

  const CreateEventPage({super.key, required this.userId});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedGender = 'Herkes'; // Default gender option
  DateTime? _selectedDate;
  bool _isLoading = false;
  final EventService _eventService = EventService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Validate inputs
  bool _isValidInput() {
    return _titleController.text.isNotEmpty &&
        _locationController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty &&
        _selectedDate != null;
  }

  // Handle event creation
  Future<void> _createEvent() async {
    if (!_isValidInput()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final event = Event(
        title: _titleController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        gender: _selectedGender,
        duration: _selectedDate!,
        creatorId: widget.userId,
      );

      final success = await _eventService.createEvent(event);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Etkinlik "${event.title}" oluşturuldu')),
        );
        _resetForm();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik oluşturulamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _locationController.clear();
    _descriptionController.clear();
    setState(() {
      _selectedGender = 'Herkes';
      _selectedDate = null;
    });
  }

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6F2DBD);
    const Color darkColor = Color(0xFF0E1116);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Etkinlik Oluştur',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/palm-recognition.png',
                  width: 250,
                  height: 250,
                ),
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
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Başlığı',
                    hintText: 'Örn: Basketbol Maçı',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.event),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bu alan zorunludur' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Konum',
                    hintText: 'Örn: Mahalle Basketbol Sahası',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bu alan zorunludur' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    hintText: 'Örn: Herkese açık basketbol oyunu',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Bu alan zorunludur' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(
                    labelText: 'Katılımcı Cinsiyeti',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.people),
                  ),
                  items: ['Herkes', 'Erkek', 'Kadın']
                      .map((gender) => DropdownMenuItem(
                            value: gender,
                            child: Text(gender),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedGender = value);
                    }
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Etkinlik Süresi (Son Tarih)',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.calendar_today),
                        hintText: _selectedDate == null
                            ? 'Tarih seçin'
                            : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                      ),
                      validator: (value) =>
                          _selectedDate == null ? 'Tarih seçiniz' : null,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState?.validate() ?? false) {
                            _createEvent();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          'Etkinliği Paylaş',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}