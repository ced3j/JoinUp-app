import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için
import 'package:join_up/home_screen.dart';
// Etkinlik modeli - Verileri tutacak sınıf
class Event {
  final String title;         // Etkinlik başlığı
  final String location;      // Etkinlik yeri
  final String description;   // Açıklama
  final String gender;        // Katılımcı cinsiyeti (Herkes/Erkek/Kadın)
  final DateTime duration;    // Etkinlik bitiş tarihi
  final String creatorId;     // Etkinliği oluşturan kullanıcı ID'si

  Event({
    required this.title,
    required this.location,
    required this.description,
    required this.gender,
    required this.duration,
    required this.creatorId,
  });
}

// Etkinlik servis arayüzü - Soyut sınıf
abstract class EventServiceInterface {
  Future<bool> createEvent(Event event); // Etkinlik oluşturma metodu
}

// Etkinlik servis implementasyonu - Somut sınıf
class EventService implements EventServiceInterface {
  @override
  Future<bool> createEvent(Event event) async {
    try {
      // API çağrısı simülasyonu (1 saniye bekletiyoruz)
      await Future.delayed(const Duration(seconds: 1));
      debugPrint('Event created: ${event.title}'); // Konsola log yazdırma
      return true; // Başarılı durum
    } catch (e) {
      debugPrint('Error creating event: $e'); // Hata durumunda log
      return false; // Başarısız durum
    }
  }
}

// Etkinlik Oluşturma Sayfası Widget'ı
class CreateEventPage extends StatefulWidget {
  final String userId; // Kullanıcı ID'si (dışarıdan alınacak)

  const CreateEventPage({
    super.key,
    required this.userId,
  });

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

// Etkinlik Oluşturma Sayfası State Sınıfı
class _CreateEventPageState extends State<CreateEventPage> {
  // Form kontrolü için global key
  final _formKey = GlobalKey<FormState>();
  
  // Text field controller'ları
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Dropdown seçimi için değişken
  String _selectedGender = 'Herkes';
  
  // Tarih seçimi için değişken
  DateTime? _selectedDate;
  
  // Yükleme durumu
  bool _isLoading = false;
  
  // Servis örneği
  final EventService _eventService = EventService();

  // Etkinlik oluşturma fonksiyonu
  Future<void> _createEvent() async {
    // Form validasyonu
    if (!_formKey.currentState!.validate()) return;
    
    // Tarih seçilmiş mi kontrolü
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir tarih seçin')),
      );
      return;
    }

    setState(() => _isLoading = true); // Yükleme başladı

    try {
      // Yeni etkinlik nesnesi oluştur
      final event = Event(
        title: _titleController.text,
        location: _locationController.text,
        description: _descriptionController.text,
        gender: _selectedGender,
        duration: _selectedDate!,
        creatorId: widget.userId,
      );

      // Servis üzerinden etkinlik oluştur
      final success = await _eventService.createEvent(event);

      if (success) {
        _resetForm(); // Formu temizle
        // Başarı mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${event.title}" etkinliği oluşturuldu')),
        );
      } else {
        // Hata mesajı göster
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Etkinlik oluşturulamadı')),
        );
      }
    } catch (e) {
      // Beklenmeyen hata durumu
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false); // Yükleme bitti
    }
  }

  // Formu sıfırlama fonksiyonu
  void _resetForm() {
    _formKey.currentState?.reset(); // Form state'ini resetle
    setState(() {
      _selectedGender = 'Herkes'; // Varsayılan cinsiyet
      _selectedDate = null; // Tarihi temizle
    });
  }

  // Tarih seçme fonksiyonu
  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(), // Bugünün tarihi ile başla
      firstDate: DateTime.now(), // Seçilebilir en eski tarih
      lastDate: DateTime.now().add(const Duration(days: 365)), // 1 yıl sonrasına kadar
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked); // Seçilen tarihi kaydet
    }
  }

  // Widget dispose edilirken controller'ları temizle
  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // UI oluşturma
  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF6F2DBD); // Ana renk
    const darkColor = Color(0xFF0E1116); // Koyu renk

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
          onPressed: (){
            Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context)=>HomePage()), // Geri Tuşu
            );
          },
          ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey, // Form key'i bağla
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              
              // Başlık
              const Text(
                'Etkinlik Bilgilerini Girin',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkColor,
                ),
              ),
              const SizedBox(height: 8),
              
              // Açıklama metni
              const Text(
                'Etkinliğinizin detaylarını aşağıda belirtin.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              
              // Etkinlik başlığı input
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik Başlığı',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.event),
                ),
                validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),
              
              // Konum input
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Konum',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),
              
              // Açıklama input
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Bu alan zorunludur' : null,
              ),
              const SizedBox(height: 16),
              
              // Cinsiyet seçim dropdown
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
                onChanged: (value) => setState(() => _selectedGender = value!),
              ),
              const SizedBox(height: 16),
              
              // Tarih seçim alanı
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
              
              // Gönder butonu
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
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Etkinliği Paylaş', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}