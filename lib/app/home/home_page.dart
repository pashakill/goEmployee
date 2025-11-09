import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // --- 2. TAMBAHKAN STATE & HELPER ---
  User? _currentUser;
  bool _isLoading = true;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final SessionManager _sessionManager = SessionManager();

  // --- 3. TAMBAHKAN INITSTATE UNTUK LOAD DATA ---
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // --- 4. TAMBAHKAN FUNGSI LOAD DATA ---
  /// Melakukan 'SELECT' data user (berdasarkan asumsi 1 user)
  Future<void> _loadUserData() async {
    try {
      // Panggil fungsi getSingleUser (sesuai permintaan terakhir Anda)
      final User? user = await _dbHelper.getSingleUser();

      if (user != null) {
        // Sukses! Simpan data ke state
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        // Gagal (Tabel 'users' ternyata kosong)
        _forceLogout(); // Paksa kembali ke login
      }
    } catch (e) {
      // Error saat loading data
      print("HomePage Error: $e");
      _forceLogout();
    }
  }

  // --- 5. TAMBAHKAN FUNGSI LOGOUT ---
  /// Fungsi untuk logout dan kembali ke Login
  Future<void> _forceLogout() async {
    await _dbHelper.deleteCurrentUserAndLogout();
    if (mounted) {
      AppNavigator.offAll(Routes.login);
    }
  }

  // --- 6. MODIFIKASI WIDGET BUILD ---
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Tampilkan loading ATAU konten utama
        body: _isLoading
            ? _buildLoading() // Tampilkan spinner saat loading
            : _buildHomeContent(), // Tampilkan UI utama jika selesai
      ),
    );
  }

  /// Widget untuk tampilan loading (dengan gradient)
  Widget _buildLoading() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800, // Hijau tua
            Colors.green.shade400, // Hijau lebih terang
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }

  /// Widget untuk UI Home utama (diambil dari kode Anda)
  Widget _buildHomeContent() {
    // Safety check, seharusnya tidak terjadi jika _forceLogout() benar
    if (_currentUser == null) {
      return const Center(child: Text('Gagal memuat data.'));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade800, // Hijau tua
            Colors.green.shade400, // Hijau lebih terang
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 40,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'GoEmployee',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    SvgImageWithColor(
                      color: Colors.white,
                      path: 'assets/icons/ic_notification.svg',
                      width: 24,
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    // --- (TAMBAHKAN LOGOUT ONTAP) ---
                    GestureDetector(
                      onTap: _forceLogout, // Panggil fungsi logout
                      child: SvgImageWithColor(
                        color: Colors.white,
                        path: 'assets/icons/ic_setting.svg',
                        width: 32,
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(
              height: 16,
            ),
            // --- (KIRIM DATA USER KE CARD) ---
            // (Pastikan ContentCardHomePage bisa menerima 'user')
            RoundedCardWidget(widget: ContentCardHomePage(user: _currentUser!)),
            const SizedBox(height: 16),
            RoundedCardWidget(widget: MenuGridWidget()),
            // Expanded agar ListView punya tinggi terbatas
            const SizedBox(height: 16),
            RoundedCardWidget(
                widget: Container(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              'Pemberitahuan'),
                          SizedBox(
                            height: 20,
                          ),
                          Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.asset(
                                    'assets/image/null_notifcation.jpg',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      'Tidak ada pemberitahuan'),
                                ],
                              ))
                        ]))),
          ],
        ),
      ),
    );
  }
}