import 'package:flutter/material.dart';

class FilterScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterScreen({super.key, required this.onApplyFilters});

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Filtre değerleri
  String? selectedCategory;
  DateTime? selectedDate;
  double? maxDistance; // km olarak
  RangeValues attendeesRange = const RangeValues(1, 100);
  String selectedGender = 'Herkes';

  final categories = ['Spor', 'Sosyal', 'Eğitim', 'Kitap', 'Eğlence', 'Diğer'];
  final genders = ['Herkes', 'Erkek', 'Kadın'];

  Future<void> _pickDate() async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: DateTime(today.year + 2),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void _applyFilters() {
    Map<String, dynamic> filters = {
      'category': selectedCategory,
      'date': selectedDate,
      'maxDistance': maxDistance,
      'attendeesMin': attendeesRange.start.toInt(),
      'attendeesMax': attendeesRange.end.toInt(),
      'gender': selectedGender,
    };
    widget.onApplyFilters(filters);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtreleme'),
        actions: [
          TextButton(
            onPressed: _applyFilters,
            child: const Text('Uygula', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Kategori seçimi
                const Text('Kategori'),
                const SizedBox(height: 10), // 10 piksel boşluk
                
                Wrap(
                  spacing: 8,
                  
                  children:
                      categories.map((cat) {
                        final isSelected = selectedCategory == cat;
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selectedCategory = selected ? cat : null;
                            });
                          },
                        );
                      }).toList(),
                ),
                const SizedBox(height: 10),

                // Tarih seçimi
                ListTile(
                  title: const Text('En yakın tarih'),
                  subtitle: Text(
                    selectedDate != null
                        ? '${selectedDate!.day}.${selectedDate!.month}.${selectedDate!.year}'
                        : 'Seçilmedi',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickDate,
                  ),
                ),
                const Divider(),

                // Konum mesafe filtresi
                ListTile(
                  title: const Text('Maksimum mesafe (km)'),
                  subtitle: Text(
                    maxDistance != null
                        ? '${maxDistance!.toStringAsFixed(1)} km'
                        : 'Seçilmedi',
                  ),
                  trailing: SizedBox(
                    width: 150,
                    child: Slider(
                      value: maxDistance ?? 50,
                      min: 1,
                      max: 100,
                      divisions: 99,
                      label: maxDistance?.toStringAsFixed(1) ?? '50',
                      onChanged: (value) {
                        setState(() {
                          maxDistance = value;
                        });
                      },
                    ),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Kişi sayısı aralığı
                const Text('Kişi Sayısı Aralığı'),
                
                const SizedBox(height: 2), 
                RangeSlider(
                  values: attendeesRange,
                  min: 1,
                  max: 100,
                  divisions: 99,
                  labels: RangeLabels(
                    attendeesRange.start.round().toString(),
                    attendeesRange.end.round().toString(),
                  ),
                  onChanged: (range) {
                    setState(() {
                      attendeesRange = range;
                    });
                  },
                ),
                const Divider(),

                // Cinsiyet filtresi
               const SizedBox(height: 10),

                const Text('Katılımcı Cinsiyeti'),
                const SizedBox(height: 10), 
                Wrap(
                  spacing: 8,
                  children:
                      genders.map((gender) {
                        final isSelected = selectedGender == gender;
                        return ChoiceChip(
                          label: Text(gender),
                          selected: isSelected,
                          onSelected: (_) {
                            setState(() {
                              selectedGender = gender;
                            });
                          },
                        );
                      }).toList(),
                ),
              ],
            ),
          ),

          // En alttaki sarı buton
          Padding(
          padding: const EdgeInsets.only(
              top: 8,
              bottom: 60,
              left: 16,
              right: 16,
            ), // üst padding azaldı
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(220, 255, 235, 58),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _applyFilters,
                child: const Text(
                  'Listele',
                  style: TextStyle(
                    color: Color.fromARGB(255, 53, 0, 71),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

    );
  }
}
