import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  DateTime? _tanggalMulai;
  DateTime? _tanggalAkhir;
  String _kunciLokasi = 'yes';
  late DateTime _tanggalPengajuan;
  Function()? _onDinasAdded;

  final TextEditingController _cariAlamatController =
  TextEditingController();

  bool _isSearchingAddress = false;

  // --- State untuk Google Map ---
  final Completer<GoogleMapController> _mapController = Completer();

  // --- 2. PERUBAHAN STATE UNTUK LOKASI ---
  // Posisi default jika GAGAL mendapatkan lokasi
  static const LatLng _defaultPosition = LatLng(-6.2088, 106.8456); // Jakarta

  late LatLng _initialPosition; // Posisi awal dari perangkat
  late LatLng _currentMapPosition;
  bool _isLoading = true; // State untuk loading
  // --- Akhir Perubahan State ---
  var alamatSaatIni;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  DinasModel? data;
  bool isEdit = false;

  @override
  void initState() {
    super.initState();
    _loadEditData();
  }

  void _loadEditData() {
    _tanggalPengajuan = DateTime.now(); // BARU
    _tglPengajuanController.text = DateFormat('dd-MM-yyyy').format(_tanggalPengajuan); // BARU

    final args = Get.arguments;
    _onDinasAdded = args?['onDinasAdded'];
    if (args != null && args['editDinas'] != null) {
      data = args['editDinas'];
      isEdit = true;
      _tanggalMulai = DateTime.tryParse(data!.tanggalMulai);
      _tanggalAkhir = DateTime.tryParse(data!.tanggalSelesai);

      _tglMulaiController.text =
          DateFormat('dd-MM-yyyy').format(_tanggalMulai!);
      _tglAkhirController.text =
          DateFormat('dd-MM-yyyy').format(_tanggalAkhir!);

      _latController.text = data!.latitude;
      _longController.text = data!.longTitude;
      _alamatController.text = data!.alamat;
      _alasanController.text = data!.alasan;

      _initialPosition = LatLng(
        double.parse(data!.latitude),
        double.parse(data!.longTitude),
      );

      _currentMapPosition = _initialPosition;

      _isLoading = false;
      _setInitialPosition(LatLng(double.parse(data!.latitude), double.parse(data!.longTitude)));
    }else{
      // 3. Panggil fungsi untuk mengambil lokasi saat init
      _fetchCurrentLocation();
    }
  }

  Future<void> _updateLatLongFields(
      LatLng position,
      ) async {
    if (!mounted) return;

    setState(() {
      _currentMapPosition = position;
      _latController.text =
          position.latitude.toStringAsFixed(6);
      _longController.text =
          position.longitude.toStringAsFixed(6);
    });

    try {
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;

        final String fullAddress = [
          place.name,
          place.street,
          place.subLocality,
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.postalCode,
          place.country,
        ]
            .where(
              (value) =>
          value != null &&
              value.trim().isNotEmpty,
        )
            .map((value) => value!.trim())
            .toSet()
            .join(', ');

        setState(() {
          _alamatController.text = fullAddress;
          alamatSaatIni = fullAddress;
        });
      } else {
        setState(() {
          _alamatController.text =
          'Alamat tidak ditemukan';
          alamatSaatIni = '';
        });
      }
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _alamatController.text =
        'Gagal mengambil detail alamat';
        alamatSaatIni = '';
      });

      debugPrint('Geocoding error: $error');
    }
  }

  Future<void> _cariAlamat() async {
    FocusScope.of(context).unfocus();

    final String keyword =
    _cariAlamatController.text.trim();

    if (keyword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Masukkan alamat yang ingin dicari',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isSearchingAddress) return;

    setState(() {
      _isSearchingAddress = true;
    });

    try {
      final List<Location> locations =
      await locationFromAddress(keyword);

      if (!mounted) return;

      if (locations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Alamat tidak ditemukan',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final Location location = locations.first;

      final LatLng targetPosition = LatLng(
        location.latitude,
        location.longitude,
      );

      final GoogleMapController controller =
      await _mapController.future;

      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: targetPosition,
            zoom: 17,
          ),
        ),
      );

      if (!mounted) return;

      setState(() {
        _initialPosition = targetPosition;
        _currentMapPosition = targetPosition;
      });

      await _updateLatLongFields(
        targetPosition,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lokasi berhasil ditemukan',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal mencari alamat: $error',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingAddress = false;
        });
      }
    }
  }

  Widget _buildAddressSearchField() {
    return TextFormField(
      controller: _cariAlamatController,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        labelText: 'Cari Alamat',
        hintText:
        'Contoh: Jalan Sudirman, Jakarta',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(
          Icons.search,
        ),
        suffixIcon: _isSearchingAddress
            ? const Padding(
          padding: EdgeInsets.all(12),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        )
            : IconButton(
          tooltip: 'Cari alamat',
          onPressed: _cariAlamat,
          icon: const Icon(
            Icons.location_searching,
          ),
        ),
      ),
      onFieldSubmitted: (_) {
        _cariAlamat();
      },
    );
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
  void _setInitialPosition(
      LatLng position, [
        String? message,
      ]) {
    if (!mounted) return;

    if (message != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
    }

    setState(() {
      _initialPosition = position;
      _currentMapPosition = position;
      _isLoading = false;
    });

    _updateLatLongFields(position);
  }


  @override
  void dispose() {
    _tglMulaiController.dispose();
    _tglAkhirController.dispose();
    _latController.dispose();
    _longController.dispose();
    _alasanController.dispose();
    _alamatController.dispose();
    _tglPengajuanController.dispose();
    _cariAlamatController.dispose();

    super.dispose();
  }

  // ... (Fungsi _pilihTanggalMulai dan _pilihTanggalAkhir tetap sama) ...
  Future<void> _pilihTanggalMulai(
      BuildContext context,
      ) async {
    final DateTime? pickedDate =
    await DatePickerHelper.pickDate(context);

    if (pickedDate == null || !mounted) return;

    setState(() {
      _tanggalMulai = DateUtils.dateOnly(pickedDate);

      _tglMulaiController.text =
          DateFormat('dd-MM-yyyy').format(
            _tanggalMulai!,
          );

      // Reset tanggal akhir jika lebih kecil
      // daripada tanggal mulai.
      if (_tanggalAkhir != null &&
          _tanggalAkhir!.isBefore(_tanggalMulai!)) {
        _tanggalAkhir = null;
        _tglAkhirController.clear();
      }
    });

    _formKey.currentState?.validate();
  }

  Future<void> _pilihTanggalAkhir(
      BuildContext context,
      ) async {
    if (_tanggalMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pilih tanggal mulai terlebih dahulu',
          ),
        ),
      );
      return;
    }

    final DateTime? pickedDate =
    await DatePickerHelper.pickDate(context);

    if (pickedDate == null || !mounted) return;

    final DateTime selectedDate =
    DateUtils.dateOnly(pickedDate);

    setState(() {
      _tanggalAkhir = selectedDate;

      _tglAkhirController.text =
          DateFormat('dd-MM-yyyy').format(
            selectedDate,
          );
    });

    _formKey.currentState?.validate();
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
            children: [
              SizedBox(height: 8),
              Text(
                isEdit ? "Edit Dinas" : "Pengajuan Dinas",
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
      body: BlocConsumer<DinasBloc, DinasState>(
        listener: (context, state) async {

          if (state is DinasPageGlobalErorr) {
            LoadingDialog.hide(context);
            final error = state.error;

            if (error is NoInternetError) {
              ErrorBottomSheet.show(
                context,
                message: "Tidak Ada Koneksi Internet",
              );
            } else if (error is TimeoutError) {
              ErrorBottomSheet.show(
                context,
                message: "Server Lambat",
              );
            } else if (error is ServerError) {
              ErrorBottomSheet.show(
                context,
                message: "Server error ${error.code}",
              );
            } else {
              ErrorBottomSheet.show(
                context,
                message: "${error.message}",
              );
            }
          }

          if(state is EditDinasSuccessState){
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sukses mengubah data Dinas')),
            );

            _onDinasAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          }

          if (state is DinasPageLoadingState) {
            LoadingDialog.show(context, message: "Tunggu Sebentar...");
          }

          if (state is AddDinasSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Sukses menambahkan data Dinas')),
            );

            _onDinasAdded?.call();
            LoadingDialog.hide(context);
            Get.back();
          } else if (state is DinasPageFailedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal Menambahkan Cuti: ${state.error}')),
            );
            LoadingDialog.hide(context);
          }
        },
        builder: (context, state) {
          return Stack(
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
                        child: Form(
                          key: _formKey,
                          autovalidateMode:
                          AutovalidateMode.onUserInteraction,
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

                              const Text(
                                'Cari Lokasi Dinas',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _buildAddressSearchField(),

                              const SizedBox(height: 16),

                              _buildReadOnlyTextField(_tglPengajuanController, 'Tanggal Pengajuan'),

                              const SizedBox(height: 16),

                              // --- Input Tanggal ---
                              Row(
                                children: [
                                  Expanded(
                                    child:  _buildDatePickerField(
                                      label: 'Tanggal Mulai',
                                      controller: _tglMulaiController,
                                      onTap: () =>
                                          _pilihTanggalMulai(context),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Wajib dipilih';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDatePickerField(
                                      label: 'Tanggal Akhir',
                                      controller: _tglAkhirController,
                                      onTap: () =>
                                          _pilihTanggalAkhir(context),
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Wajib dipilih';
                                        }

                                        if (_tanggalMulai != null &&
                                            _tanggalAkhir != null &&
                                            _tanggalAkhir!
                                                .isBefore(_tanggalMulai!)) {
                                          return 'Tanggal tidak valid';
                                        }

                                        return null;
                                      },
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
                                      _latController,
                                      'Latitude',
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Latitude kosong';
                                        }

                                        if (double.tryParse(value.trim()) == null) {
                                          return 'Latitude tidak valid';
                                        }

                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildReadOnlyTextField(
                                      _longController,
                                      'Longitude',
                                      validator: (value) {
                                        if (value == null ||
                                            value.trim().isEmpty) {
                                          return 'Longitude kosong';
                                        }

                                        if (double.tryParse(value.trim()) == null) {
                                          return 'Longitude tidak valid';
                                        }

                                        return null;
                                      },
                                    ),
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
                              _buildReadOnlyTextField(
                                _alamatController,
                                'Alamat (Otomatis)',
                                validator: (value) {
                                  final alamat = value?.trim() ?? '';

                                  if (alamat.isEmpty) {
                                    return 'Alamat lokasi wajib tersedia';
                                  }

                                  if (alamat == 'Alamat tidak ditemukan.' ||
                                      alamat.contains(
                                        'Gagal mengambil alamat',
                                      )) {
                                    return 'Alamat lokasi tidak valid';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              // --- Field Alasan ---
                              const Text(
                                'Alasan',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _alasanController,
                                maxLines: 3,
                                autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                                decoration: const InputDecoration(
                                  labelText: 'Alasan Dinas',
                                  hintText: 'Masukkan alasan...',
                                  border: OutlineInputBorder(),
                                  alignLabelWithHint: true,
                                ),
                                validator: (value) {
                                  final alasan = value?.trim() ?? '';

                                  if (alasan.isEmpty) {
                                    return 'Alasan dinas wajib diisi';
                                  }

                                  if (alasan.length < 5) {
                                    return 'Alasan minimal 5 karakter';
                                  }

                                  return null;
                                },
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
                                  onPressed: _submitDinas,
                                  child: Text(
                                    isEdit ? 'Simpan Dinas' : 'Simpan Dinas',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        )
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Helper Widget --- (Tidak berubah)

  Widget _buildDatePickerField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onTap,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: 'Pilih tanggal',
        border: const OutlineInputBorder(),
        suffixIcon:
        const Icon(Icons.calendar_today),
      ),
      onTap: onTap,
    );
  }

  Future<void> _submitDinas() async {
    FocusScope.of(context).unfocus();

    final bool formValid =
        _formKey.currentState?.validate() ?? false;

    if (!formValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Lengkapi data pengajuan dinas',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalMulai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal mulai wajib dipilih',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalAkhir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal akhir wajib dipilih',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tanggalAkhir!.isBefore(_tanggalMulai!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tanggal akhir tidak boleh '
                'sebelum tanggal mulai',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String latitude =
    _latController.text.trim();

    final String longitude =
    _longController.text.trim();

    final String alamat =
    _alamatController.text.trim();

    final String alasan =
    _alasanController.text.trim();

    if (double.tryParse(latitude) == null ||
        double.tryParse(longitude) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Koordinat lokasi tidak valid',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final User? currentUser =
    await _dbHelper.getSingleUser();

    if (!mounted) return;

    if (currentUser == null ||
        currentUser.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Data pengguna tidak ditemukan',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final String tanggalMulai =
    convertToMysqlFormat(
      _tglMulaiController.text,
    );

    final String tanggalSelesai =
    convertToMysqlFormat(
      _tglAkhirController.text,
    );

    final DinasModel dinasBaru = DinasModel(
      userId: currentUser.id!,
      tanggalMulai: tanggalMulai,
      tanggalSelesai: tanggalSelesai,
      alamat: alamat,
      latitude: latitude,
      longTitude: longitude,
      radius: '',
      alasan: alasan,
      tanggalPengajuan:
      _tanggalPengajuan.toIso8601String(),
    );

    if (!mounted) return;

    if (isEdit) {
      if (data?.id == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ID pengajuan dinas tidak ditemukan',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      context.read<DinasBloc>().add(
        UpdateDinasEvent(
          dinasBaru,
          id: data!.id!,
          userId: currentUser.id!,
          kategori:
          PengajuanKategori.dinas.name,
          tanggal_mulai: tanggalMulai,
          tanggal_selesai: tanggalSelesai,
          alamat: alamat,
          latitude: latitude,
          longTitude: longitude,
          alasan: alasan,
        ),
      );
    } else {
      context.read<DinasBloc>().add(
        AddDinasEvent(
          dinasBaru,
          userId: currentUser.id!,
          kategori:
          PengajuanKategori.dinas.name,
          tanggal_mulai: tanggalMulai,
          tanggal_selesai: tanggalSelesai,
          alamat: alamat,
          latitude: latitude,
          longTitude: longitude,
          alasan: alasan,
        ),
      );
    }
  }

  Widget _buildReadOnlyTextField(
      TextEditingController controller,
      String label, {
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      validator: validator,
      autovalidateMode:
      AutovalidateMode.onUserInteraction,
      style: TextStyle(
        color: Colors.grey[600],
      ),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[200],
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[300]!,
          ),
        ),
      ),
    );
  }

  String convertToMysqlFormat(String dateText) {
    try {
      // dari TextField (dd-MM-yyyy)
      final parsedDate = DateFormat('dd-MM-yyyy').parse(dateText);

      // ke MySQL (yyyy-MM-dd HH:mm:ss)
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedDate);
    } catch (e) {
      throw Exception('Format tanggal tidak valid: $dateText');
    }
  }
}