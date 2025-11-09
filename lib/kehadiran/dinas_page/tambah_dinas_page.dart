import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart'; // <-- 1. IMPORT BARU

class TambahDinasPage extends StatefulWidget {
  const TambahDinasPage({super.key});

  @override
  State<TambahDinasPage> createState() => _TambahDinasPageState();
}

class _TambahDinasPageState extends State<TambahDinasPage> {
  // --- State untuk Form ---
  final TextEditingController _tglMulaiController = TextEditingController();
  final TextEditingController _tglAkhirController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _longController = TextEditingController();
  final TextEditingController _alasanController = TextEditingController();

  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;
  String _kunciLokasi = 'yes';

  // --- State untuk Google Map ---
  final Completer<GoogleMapController> _mapController = Completer();

  // --- 2. PERUBAHAN STATE UNTUK LOKASI ---
  // Posisi default jika GAGAL mendapatkan lokasi
  static const LatLng _defaultPosition = LatLng(-6.2088, 106.8456); // Jakarta

  late LatLng _initialPosition; // Posisi awal dari perangkat
  late LatLng _currentMapPosition;
  bool _isLoading = true; // State untuk loading
  // --- Akhir Perubahan State ---

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi untuk mengambil lokasi saat init
    _fetchCurrentLocation();
  }

  // --- 4. FUNGSI BARU UNTUK AMBIL LOKASI ---
  Future<void> _fetchCurrentLocation() async {
    LocationPermission permission;

    try {
      // Cek izin_page
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          // Izin ditolak, gunakan lokasi default
          _setInitialPosition(_defaultPosition, "Izin lokasi ditolak. Menggunakan lokasi default.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Izin ditolak permanen
        _setInitialPosition(_defaultPosition, "Izin lokasi ditolak permanen. Menggunakan lokasi default.");
        return;
      }

      // Izin diberikan, ambil lokasi
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      _setInitialPosition(LatLng(position.latitude, position.longitude));

    } catch (e) {
      // Error (misal: service lokasi mati)
      _setInitialPosition(_defaultPosition, "Gagal mendapatkan lokasi: $e. Menggunakan lokasi default.");
    }
  }

  // Helper untuk set state setelah lokasi didapat (atau gagal)
  void _setInitialPosition(LatLng position, [String? message]) {
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }

    setState(() {
      _initialPosition = position;
      _currentMapPosition = position;
      _isLoading = false; // Selesai loading
      // Update field
      _updateLatLongFields(position);
    });
  }
  // --- Akhir Fungsi Baru ---


  @override
  void dispose() {
    _tglMulaiController.dispose();
    _tglAkhirController.dispose();
    _latController.dispose();
    _longController.dispose();
    _alasanController.dispose();
    super.dispose();
  }

  // ... (Fungsi _pilihTanggalMulai dan _pilihTanggalAkhir tetap sama) ...
  Future<void> _pilihTanggalMulai(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalMulai ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalMulai) {
      setState(() {
        _tanggalMulai = picked;
        _tglMulaiController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _pilihTanggalAkhir(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalAkhir ?? _tanggalMulai ?? DateTime.now(),
      firstDate: _tanggalMulai ?? DateTime(2000), // Tidak bisa sebelum tgl mulai
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _tanggalAkhir) {
      setState(() {
        _tanggalAkhir = picked;
        _tglAkhirController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _updateLatLongFields(LatLng position) {
    setState(() {
      _currentMapPosition = position;
      _latController.text = position.latitude.toStringAsFixed(6);
      _longController.text = position.longitude.toStringAsFixed(6);
    });
  }

  @override
  Widget build(BuildContext context) {
    // --- 5. TAMPILKAN LOADING JIKA PERLU ---
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text("Mencari Lokasi Anda..."),
          backgroundColor: Colors.green,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    // --- Akhir Tampilan Loading ---

    // Tampilan utama setelah loading selesai
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        // ... (AppBar Anda tetap sama) ...
        preferredSize: const Size.fromHeight(85),
        child: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.white,
            onPressed: () {
              AppNavigator.back();
            },
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              SizedBox(height: 8),
              Text(
                'Pengajuan Dinas',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Pastikan kordinat anda sudah sesuai',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green.withOpacity(0.5),
          elevation: 0,
          centerTitle: true,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
      ),
      body: Stack(
        children: [
          // Latar Belakang: Google Map
          GoogleMap(
            mapType: MapType.normal,
            // --- 6. GUNAKAN _initialPosition DARI STATE ---
            initialCameraPosition: CameraPosition( // tidak lagi const
              target: _initialPosition, // Gunakan state
              zoom: 14.0,
            ),
            // --- Akhir Perubahan ---
            onMapCreated: (GoogleMapController controller) {
              if (!_mapController.isCompleted) {
                _mapController.complete(controller);
              }
            },

            // Logika Kunci Peta (dari sebelumnya)
            scrollGesturesEnabled: _kunciLokasi == 'no',
            zoomGesturesEnabled: _kunciLokasi == 'no',
            rotateGesturesEnabled: _kunciLokasi == 'no',
            tiltGesturesEnabled: _kunciLokasi == 'no',
            myLocationButtonEnabled: _kunciLokasi == 'no',
            myLocationEnabled: true,

            onCameraIdle: () {
              if (_kunciLokasi == 'no') {
                _updateLatLongFields(_currentMapPosition);
              }
            },
            onCameraMove: (CameraPosition position) {
              if (_kunciLokasi == 'no') {
                _currentMapPosition = position.target;
              }
            },
            zoomControlsEnabled: false,
          ),

          // Penanda (Pin) di tengah layar
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40.0),
              child: Icon(
                Icons.location_pin,
                color: Colors.red,
                size: 40.0,
              ),
            ),
          ),

          // Layer Atas: Bottom Sheet Form
          DraggableScrollableSheet(
            // ... (Isi Bottom Sheet tetap sama) ...
            initialChildSize: 0.5,
            minChildSize: 0.2,
            maxChildSize: 0.9,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      spreadRadius: 1.0,
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  physics: const ClampingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Handle (garis abu-abu di atas)
                        Center(
                          child: Container(
                            width: 40,
                            height: 5,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Input Tanggal ---
                        Row(
                          children: [
                            Expanded(
                              child: _buildDatePickerField(
                                context,
                                'Tanggal Mulai',
                                _tglMulaiController,
                                    () => _pilihTanggalMulai(context),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildDatePickerField(
                                context,
                                'Tanggal Akhir',
                                _tglAkhirController,
                                    () => _pilihTanggalAkhir(context),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Radio Button Kunci Lokasi ---
                        const Text(
                          'Kunci Lokasi',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Yes'),
                                value: 'yes',
                                groupValue: _kunciLokasi,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) {
                                  setState(() {
                                    _kunciLokasi = value!;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('No'),
                                value: 'no',
                                groupValue: _kunciLokasi,
                                visualDensity: VisualDensity.compact,
                                contentPadding: EdgeInsets.zero,
                                onChanged: (value) {
                                  setState(() {
                                    _kunciLokasi = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Field Latitude & Longitude ---
                        const Text(
                          'Koordinat Lokasi (Otomatis)',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildReadOnlyTextField(
                                  _latController, 'Latitude'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildReadOnlyTextField(
                                  _longController, 'Longitude'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // --- Field Alasan ---
                        const Text(
                          'Alasan',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _alasanController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'Masukkan alasan dinas_page...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- Tombol Submit ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green, // Warna hijau
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              // TODO: Logika submit form di sini
                            },
                            child: const Text(
                              'Submit Pengajuan',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // --- Helper Widget --- (Tidak berubah)

  Widget _buildDatePickerField(BuildContext context, String label,
      TextEditingController controller, VoidCallback onTap) {
    return TextField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: onTap,
    );
  }

  Widget _buildReadOnlyTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      readOnly: true,
      style: TextStyle(color: Colors.grey[600]),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
    );
  }
}