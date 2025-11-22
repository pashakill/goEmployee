import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
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
  final TextEditingController _alamatController = TextEditingController(); // BARU
  final TextEditingController _tglPengajuanController = TextEditingController(); // BARU

  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;
  String _kunciLokasi = 'yes';
  late DateTime _tanggalPengajuan;

  // --- State untuk Google Map ---
  final Completer<GoogleMapController> _mapController = Completer();

  // --- 2. PERUBAHAN STATE UNTUK LOKASI ---
  // Posisi default jika GAGAL mendapatkan lokasi
  static const LatLng _defaultPosition = LatLng(-6.2088, 106.8456); // Jakarta

  late LatLng _initialPosition; // Posisi awal dari perangkat
  late LatLng _currentMapPosition;
  bool _isLoading = true; // State untuk loading
  // --- Akhir Perubahan State ---

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    // 3. Panggil fungsi untuk mengambil lokasi saat init
    _tanggalPengajuan = DateTime.now(); // BARU
    _tglPengajuanController.text = DateFormat('dd-MM-yyyy').format(_tanggalPengajuan); // BARU
    _fetchCurrentLocation();
  }

  void _updateLatLongFields(LatLng position) async { // Tambahkan async
    setState(() {
      _currentMapPosition = position;
      _latController.text = position.latitude.toStringAsFixed(6);
      _longController.text = position.longitude.toStringAsFixed(6);
    });

    // --- Reverse Geocoding untuk Alamat --- (BARU)
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        // Gabungkan detail alamat yang relevan
        String fullAddress = [
          place.street,
          place.subLocality,
          place.locality,
          place.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _alamatController.text = fullAddress;
        });
      } else {
        setState(() {
          _alamatController.text = "Alamat tidak ditemukan.";
        });
      }
    } catch (e) {
      setState(() {
        _alamatController.text = "Gagal mengambil alamat (Jaringan Error)";
      });
      print("Geocoding Error: $e");
    }
    // --- Akhir Reverse Geocoding ---
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

                        _buildReadOnlyTextField(_tglPengajuanController, 'Tanggal Pengajuan'),

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

                        // --- Field Alamat (BARU) ---
                        const Text(
                          'Alamat Lokasi Dinas',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        _buildReadOnlyTextField(_alamatController, 'Alamat (Otomatis)'),

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
                            hintText: 'Masukkan alasan...',
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
                            onPressed: () async {
                              try {
                                // 2. Ambil user yang sedang login (sesuai cara kita sebelumnya)
                                final User? currentUser = await _dbHelper.getSingleUser();
                                if (currentUser == null || currentUser.id == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Error: Gagal mendapatkan data user!')),
                                  );
                                  return;
                                }

                                // 3. Buat model Cuti (kode Anda sudah benar)
                                final dinasBaru = DinasModel(
                                    userId: currentUser.id!,
                                    tanggalMulai: _tglMulaiController.text,
                                    tanggalSelesai: _tglAkhirController.text,
                                    alamat: _alamatController.text, latitude: _latController.text,
                                    longTitude: _longController.text, radius: '',
                                    alasan: _alasanController.text, tanggalPengajuan: _tanggalPengajuan.toString()

                                );

                                // 4. PANGGIL FUNGSI INSERT DARI DATABASEHELPER
                                //    Ini akan menyimpan data ke database SQLCipher
                                final int dinasId = await _dbHelper.insertDinas(dinasBaru);
                                print('Dinas baru berhasil disimpan ke DB dengan ID: $dinasId');
                                // 5. PANGGIL CALLBACK (kode Anda sudah benar)
                                //    Ini akan meng-update UI di halaman DaftarCutiPage
                                Get.back();
                              } catch (e) {
                                // Tangani jika ada error saat simpan ke DB
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e')),
                                );
                              }
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