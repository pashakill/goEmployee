import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goemployee/kehadiran/kehadiran_page/bloc/bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class KehadiranPage extends StatefulWidget {
  const KehadiranPage({super.key});

  @override
  State<KehadiranPage> createState() => _KehadiranPageState();
}

class _KehadiranPageState extends State<KehadiranPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;
  String _currentAddress = "Mendeteksi lokasi...";
  String _officeAddress = "Mendeteksi alamat kantor...";
  double? _distanceInMeters;
  final MobileSecurityChecker _security = MobileSecurityChecker();
  // Titik lokasi kantor
  LatLng? _officeLocation;
  String locationType = "office";
  double? checkInRadius;

  bool isCheckinDone = false;
  bool isCheckoutDone = false;

  StreamSubscription<Position>? _positionStream;

  //STATE UNTUK AMBIL DATA USER
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  User? _currentUser;
  bool _isUserDataLoading = true;


  Future<void> _loadUserData() async {
    final User? user = await _dbHelper.getSingleUser();

    if (user != null) {
      /// 🔥 CEK & RESET JIKA HARI BERBEDA
      await _dbHelper.resetIfNewDay(
        user.id!,
        user.dateNow ?? '',
      );
    }

    final updatedUser = await _dbHelper.getSingleUser();

    setState(() {
      _currentUser = updatedUser;
      _isUserDataLoading = false;
    });

    context.read<KehadiranBloc>().add(
      GetActiveLocation(
        user_id: _currentUser!.id.toString(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _processCheckOut(String checkOutTime) async {
    if (_currentUser == null || _currentUser!.id == null) return;

    final todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    /// VALIDASI: HARUS SUDAH CHECK-IN
    if (_currentUser!.dateNow != todayDate ||
        _currentUser!.timeCheckin == null ||
        _currentUser!.timeCheckin!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda belum check-in hari ini')),
      );
      return;
    }

    /// VALIDASI: JANGAN DOUBLE CHECKOUT
    if (_currentUser!.timeCheckout != null &&
        _currentUser!.timeCheckout!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Anda sudah check-out pada jam ${_currentUser!.timeCheckout}'),
        ),
      );
      return;
    }

    try {
      /// SIMPAN KE LOCAL DB
      await _dbHelper.updateUserCheckOut(
        _currentUser!.id!,
        checkOutTime,
      );

      setState(() {
        _currentUser!.timeCheckout = checkOutTime;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-Out Berhasil pada $checkOutTime')),
      );

      AppNavigator.offAll(Routes.home);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal checkout: $e')),
      );
    }
  }


  // --- 5. FUNGSI BARU UNTUK PROSES CHECK-IN ---
  Future<void> _processCheckIn(String checkInTimeString, String lateCheckinDuration) async {
    // Pastikan user sudah di-load dan tidak null
    if (_currentUser == null || _currentUser!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal: Data user tidak ditemukan!')),
      );
      return;
    }

    // --- 1. VALIDASI ---
    // Cek apakah data check-in hari ini sudah ada
    final String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    // Cek jika tanggal di DB SAMA DENGAN hari ini
    // DAN timeCheckin TIDAK kosong
    if (_currentUser!.dateNow == todayDate &&
        _currentUser!.timeCheckin != null &&
        _currentUser!.timeCheckin!.isNotEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Anda sudah check-in hari ini pada jam ${_currentUser!.timeCheckin}'),
          backgroundColor: Colors.orange[700],
        ),
      );
      return; // Hentikan fungsi
    }
    /*
    // --- AKHIR VALIDASI ---

    // --- LOGIKA PERHITUNGAN KETERLAMBATAN ---
    // 1. Ambil data dari database (misal: "08:00")
    final String? jadwalMasukString = _currentUser?.jadwalMulaiKerja;

    // 2. Ambil waktu saat ini
    final DateTime now = DateTime.now();
    final String checkInTimeString =
    DateFormat('HH:mm:ss').format(now); // misal: "08:30:15"

    String? lateCheckinDuration; // Variabel untuk menyimpan durasi

    // 3. Bandingkan (hanya jika jadwal masuk ada)
    if (jadwalMasukString != null && jadwalMasukString.isNotEmpty) {
      try {
        final format = DateFormat('HH:mm'); // Format jadwal ("08:00")
        final jadwalTime = format.parse(jadwalMasukString);

        // Parse waktu check-in (tanpa detik, agar formatnya sama)
        final checkinTimeParsed =
        format.parse(checkInTimeString.substring(0, 5)); // "08:30"

        // Cek apakah waktu check-in SETELAH jadwal masuk
        if (checkinTimeParsed.isAfter(jadwalTime)) {
          // Hitung selisihnya
          final Duration difference =
          checkinTimeParsed.difference(jadwalTime);

          // Ubah durasi menjadi format "HH:mm:ss" (misal: "00:30:00")
          lateCheckinDuration = _formatDuration(difference);
          print('Status: TERLAMBAT ${lateCheckinDuration}');
        } else {
          print('Status: TEPAT WAKTU');
          lateCheckinDuration = null; // Tidak terlambat
        }
      } catch (e) {
        print('Gagal membandingkan waktu: $e');
      }
    }
    // --- AKHIR LOGIKA KETERLAMBATAN ---
     */
    try {
      // 4. Panggil helper (fungsi ini sekarang juga menyimpan date_now)
      await _dbHelper.updateUserCheckIn(
        _currentUser!.id!,
        checkInTimeString,
        lateCheckinDuration,
      );

      // 5. (Opsional) Perbarui state UI agar sinkron
      setState(() {
        _currentUser!.timeCheckin = checkInTimeString;
        _currentUser!.lateCheckin = lateCheckinDuration;
        _currentUser!.dateNow = todayDate;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Check-In Berhasil pada $checkInTimeString ${lateCheckinDuration != null ? "(Terlambat)" : ""} ✅')),
      );

      // Kembali ke home
      AppNavigator.offAll(Routes.home);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan check-in: $e')),
      );
    }
  }

  /// Mengubah Durasi (misal: 0:30:00.000) menjadi String "HH:mm:ss"
  String _formatDuration(Duration duration) {
    // Ambil bagian "0:30:00"
    String twoDigit(int n) => n.toString().padLeft(2, '0');
    final String twoDigitMinutes = twoDigit(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigit(duration.inSeconds.remainder(60));
    // Format menjadi "HH:mm:ss"
    return "${twoDigit(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<Position> _getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _initLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = 'Layanan lokasi tidak aktif';
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = 'Izin lokasi ditolak';
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress = 'Izin lokasi ditolak permanen';
      });
      return;
    }

    // Ambil posisi pertama
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _updatePosition(position);

    // Update posisi secara real-time
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // update setiap 5 meter
      ),
    ).listen((Position pos) {
      _updatePosition(pos);
    });
  }

  Future<void> _updatePosition(Position position) async {
    if (_officeLocation == null) return;

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    // Hitung jarak ke kantor
    _distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      _officeLocation!.latitude,
      _officeLocation!.longitude,
    );

    // Ambil alamat
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        _currentAddress =
        "${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.country}";
      } else {
        _currentAddress = "Alamat tidak ditemukan";
      }
    } catch (e) {
      _currentAddress = "Gagal mengambil alamat";
    }

    // Update UI
    setState(() {});

    // Geser kamera ke lokasi user
    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
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
              SizedBox(height: 8,),
              Text(
                'Kehadiran',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pastikan kordinat anda sudah sesuai',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                ),
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
      body: BlocConsumer<KehadiranBloc, KehadiranState>(
          listener: (context, state) async {
            if(state is GetActiveLocationSuccess){
              LoadingDialog.hide(context);

              setState(() {
                locationType = state.activeLocationResponseModel.data!.type ?? "office";
                _officeLocation = LatLng(
                  state.activeLocationResponseModel.data!.lat,
                  state.activeLocationResponseModel.data!.lng,
                );
                checkInRadius = state.activeLocationResponseModel.data!.radius;
              });
              context.read<KehadiranBloc>().add(
                GetStatusAbsen(
                  user_id: _currentUser!.id.toString(),
                ),
              );

              _restartLocationStream();
              _getOfficeAddress();
            }

            if(state is GetStatusAbsenSuccess){
              LoadingDialog.hide(context);

              setState(() {
                isCheckinDone = state.statusKehadiranModel.checkin;
                isCheckoutDone = state.statusKehadiranModel.checkout;
              });
            }

            if (state is KehadiranPageGlobalErorr) {
              final error = state.error;
              LoadingDialog.hide(context);

              if (error is NoInternetError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Tidak ada Koneksi Internet')),
                );
              } else if (error is TimeoutError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server Lambat')),
                );
              } else if (error is ServerError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Server error ${state.error.message}')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${state.error.message}')),
                );
              }
            }

            if (state is CheckoutSuccess) {
              final jamKeluar =
                  state.kehadiranModel.kehadiranResponse?.jamKeluar ?? '';

              await _processCheckOut(jamKeluar);
              LoadingDialog.hide(context);
            }


            if (state is CheckinSuccess) {
              _processCheckIn(state.kehadiranModel.kehadiranResponse?.jamMasuk ?? '',
                  state.kehadiranModel.kehadiranResponse?.terlambat ?? '');

              LoadingDialog.hide(context);
            }

            if(state is CheckinLoading){
              LoadingDialog.show(context, message: "Tunggu Sebentar...");
            }

            if(state is CheckinFailure){
              LoadingDialog.hide(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Checkin Gagal: ${state.error}')),
              );
            }

          },
          builder: (context, state){
            return Stack(
              children: [
                // Google Map
                _currentPosition == null
                    ? const Center(child: CircularProgressIndicator())
                    : GoogleMap(
                  key: ValueKey(_officeLocation),
                  mapType: MapType.normal,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 17,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: {
                    Marker(
                      markerId: const MarkerId("current"),
                      position: _currentPosition!,
                      infoWindow: const InfoWindow(title: "Lokasi Anda"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
                    ),
                    Marker(
                      markerId: const MarkerId("office"),
                      position: _officeLocation!,
                      infoWindow: const InfoWindow(title: "Kantor"),
                      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                    ),
                  },
                  circles: {
                    Circle(
                      circleId: const CircleId("officeRadius"),
                      center: _officeLocation!,
                      radius: checkInRadius!,
                      fillColor: (_distanceInMeters != null && _distanceInMeters! <= checkInRadius!)
                          ? Colors.green.withOpacity(0.2)
                          : Colors.red.withOpacity(0.2),
                      strokeColor: (_distanceInMeters != null && _distanceInMeters! <= checkInRadius!)
                          ? Colors.green
                          : Colors.red,
                      strokeWidth: 2,
                    ),
                  },
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

                // Bottom Sheet
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                FloatingActionButton(
                                  heroTag: "btnCurrent",
                                  backgroundColor: Colors.green,
                                  mini: true,
                                  onPressed: () {
                                    if (_currentPosition != null && _mapController != null) {
                                      _mapController!.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: _currentPosition!, zoom: 17),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.my_location, color: Colors.white),
                                ),
                                FloatingActionButton(
                                  heroTag: "btnOffice",
                                  backgroundColor: Colors.red,
                                  mini: true,
                                  onPressed: () {
                                    if (_mapController != null) {
                                      _mapController!.animateCamera(
                                        CameraUpdate.newCameraPosition(
                                          CameraPosition(target: _officeLocation!, zoom: 17),
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(Icons.apartment, color: Colors.white),
                                ),
                              ],
                            )),
                        // Bottom Sheet
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 10,
                                offset: Offset(0, -3),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Alamat
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, color: Colors.redAccent),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      locationType == "dinas"
                                          ? _officeAddress
                                          : _currentAddress,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Jarak ke kantor
                              if (_distanceInMeters != null)
                                Text(
                                  'Jarak ke kantor: ${_distanceInMeters!.toStringAsFixed(1)} meter',
                                  style: TextStyle(
                                    color: (_distanceInMeters! <= checkInRadius!) ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              CustomPaint(
                                size: Size(double.infinity, 40),
                                painter: LinePainter(color: Colors.grey, strokeWidth: 1, isDashed: false),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Column(
                                        children: [
                                          Text('Jadwal Mulai Kerja',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500)),
                                          Text(_currentUser?.jadwalMulaiKerja ?? '--:--',

                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold))
                                        ],
                                      ),
                                      SizedBox(width: 30,),
                                      Column(
                                        children: [
                                          Text('Jadwal Selesai Kerja',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500
                                              )),
                                          Text(_currentUser?.jadwalSelesaiKerja ?? '--:--',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          )
                                        ],
                                      )
                                    ],
                                  )
                                ],
                              ),
                              SizedBox(height: 16,),
                              // Tombol Check In
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: (_distanceInMeters != null &&
                                        _distanceInMeters! <= checkInRadius! &&
                                        !isCheckoutDone)
                                        ? (isCheckinDone ? Colors.orange : Colors.green)
                                        : Colors.grey,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: (_distanceInMeters != null &&
                                      checkInRadius != null &&
                                      _distanceInMeters! <= checkInRadius! &&
                                      !isCheckoutDone)
                                      ? () async {
                                    final position = await _getCurrentPosition();

                                    /// 🔐 SECURITY
                                    final isSafe = await _security.isSafe(position);

                                    if (!isSafe) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Fake GPS / Device tidak aman"),
                                        ),
                                      );
                                      return;
                                    }

                                    /// ===== CHECKIN =====
                                    if (!isCheckinDone) {
                                      context.read<KehadiranBloc>().add(
                                        CheckinButtonPressed(
                                          user_id: _currentUser!.id.toString(),
                                          latitude: position.latitude.toString(),
                                          longitude: position.longitude.toString(),
                                        ),
                                      );
                                    }

                                    /// ===== CHECKOUT =====
                                    else {
                                      context.read<KehadiranBloc>().add(
                                        CheckoutButtonPressed(
                                          user_id: _currentUser!.id.toString(),
                                          latitude: position.latitude.toString(),
                                          longitude: position.longitude.toString(),
                                        ),
                                      );
                                    }
                                  }
                                      : null,
                                  icon: Icon(
                                    isCheckoutDone
                                        ? Icons.block
                                        : (isCheckinDone ? Icons.logout_rounded : Icons.login_rounded),
                                    color: Colors.white,
                                  ),

                                  label: Text(
                                    isCheckoutDone
                                        ? 'Sudah Absen Hari Ini'
                                        : (isCheckinDone ? 'Check Out' : 'Check In'),
                                    style: const TextStyle(color: Colors.white, fontSize: 16),
                                  ),
                                ),
                              ),
                              SizedBox(height: 32,),
                            ],
                          ),
                        ),
                      ],
                    )
                ),
              ],
            );
          },
          )
    );
  }

  void _restartLocationStream() {
    _positionStream?.cancel();
    _initLocation();
  }

  Future<void> _getOfficeAddress() async {
    if (_officeLocation == null) return;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _officeLocation!.latitude,
        _officeLocation!.longitude,
      );

      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;

        setState(() {
          _officeAddress =
          "${placemark.street}, ${placemark.subLocality}, ${placemark
              .locality}, ${placemark.administrativeArea}, ${placemark
              .country}";
        });
      } else {
        setState(() {
          _officeAddress = "--:--";
        });
      }
    } catch (e) {
      setState(() {
        _officeAddress = "--:--";
      });
    }
  }
}
