import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key});

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  LatLng? _pickedLocation;
  GoogleMapController?
  _mapController; // Optionally remove this line if not used

  LatLng _initialCameraPosition = const LatLng(
    39.9334,
    32.8597,
  ); // Varsayılan: Ankara
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }

  Future<void> _determineInitialPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servislerinin açık olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Konum servisleri kapalı. Lütfen etkinleştirin.';
          // _initialCameraPosition varsayılan değerde kalır
          _isLoading = false;
        });
      }
      // Kullanıcıyı ayarlara yönlendirmek için bir diyalog gösterebilirsiniz
      // await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          setState(() {
            _errorMessage = 'Konum izni reddedildi.';
            _isLoading = false;
          });
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Konum izinleri kalıcı olarak reddedildi. Lütfen uygulama ayarlarından izin verin.';
          _isLoading = false;
        });
      }
      // Kullanıcıyı uygulama ayarlarına yönlendirmek için bir diyalog gösterebilirsiniz
      // await Geolocator.openAppSettings();
      return;
    }

    // İzinler verildi, mevcut konumu al
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      if (mounted) {
        setState(() {
          _initialCameraPosition = LatLng(
            position.latitude,
            position.longitude,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Konum alınamadı: ${e.toString()}';
          // _initialCameraPosition varsayılan değerde kalır
          _isLoading = false;
        });
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    if (mounted) {
      // Widget'ın hala ağaçta olduğundan emin ol
      _mapController = controller;
    }
  }

  void _onTap(LatLng position) {
    setState(() {
      _pickedLocation = position;
    });
    // Seçilen konuma kamerayı animasyonla götür
    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 17, // Biraz daha yakınlaşabiliriz
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konum Seç'),
        actions: [
          if (_pickedLocation != null)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                Navigator.pop(context, _pickedLocation);
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else if (_errorMessage != null &&
              _initialCameraPosition ==
                  const LatLng(
                    39.9334,
                    32.8597,
                  )) // Sadece hata varsa ve konum alınamadıysa mesaj göster
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            )
          else // Haritayı göster (hata olsa bile varsayılan konumla)
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _pickedLocation ?? _initialCameraPosition,
                zoom: 15,
              ),
              onTap: _onTap,
              myLocationEnabled:
                  true, // Kullanıcının kendi konumunu haritada gösterir
              myLocationButtonEnabled:
                  true, // Kullanıcının konumuna gitme butonu
              markers:
                  _pickedLocation == null
                      ? {}
                      : {
                        Marker(
                          markerId: const MarkerId('pickedLocation'),
                          position: _pickedLocation!,
                          infoWindow: InfoWindow(
                            title: 'Seçilen Konum',
                            snippet:
                                '${_pickedLocation!.latitude.toStringAsFixed(5)}, ${_pickedLocation!.longitude.toStringAsFixed(5)}',
                          ),
                        ),
                      },
            ),
          // Hata mesajını haritanın üzerinde göstermek isterseniz:
          if (_errorMessage != null && !_isLoading)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.red.withAlpha((0.7 * 255).toInt()),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton:
          _isLoading || _pickedLocation == null
              ? null // Yükleniyorsa veya konum seçilmediyse FAB'ı gizle
              : FloatingActionButton.extended(
                onPressed: () {
                  if (_pickedLocation != null) {
                    Navigator.pop(context, _pickedLocation);
                  }
                },
                label: const Text("Bu Konumu Seç"),
                icon: const Icon(Icons.check),
              ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
