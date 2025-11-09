import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();

    _checkIfUsersExist();
  }

  /// Memeriksa apakah tabel user sudah terisi
  Future<void> _checkIfUsersExist() async {
    // Beri jeda 2 detik agar logo tetap terlihat
    await Future.delayed(const Duration(seconds: 2));

    // 1. Panggil fungsi yang baru kita buat
    final bool isUserTableFilled = await _dbHelper.hasUsers();

    // 2. Tentukan halaman tujuan
    if (isUserTableFilled) {
      // --- SUDAH TERISI ---
      // Arahkan ke Halaman Login untuk validasi
      print("SplashScreen: Tabel 'users' sudah terisi. Mengalihkan ke Login.");
      AppNavigator.offAll(Routes.home);
    } else {
      // --- MASIH KOSONG ---
      // Arahkan ke Halaman Register untuk membuat user pertama
      print("SplashScreen: Tabel 'users' kosong. Mengalihkan ke Register.");
      // Anda perlu membuat halaman RegisterPage()
      // _navigateTo(const RegisterPage());

      // Untuk sementara, kita bisa arahkan ke Login juga jika RegisterPage belum ada
      AppNavigator.offAll(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      // Tampilkan logo dan teks di tengah layar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti FlutterLogo dengan logo Anda
            Icon(
              Icons.shield_outlined, // Ganti dengan logo Anda
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            const Text(
              'GoEmployee',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            // Opsional: Tambahkan loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(Colors.blue),
            ),
          ],
        ),
      ),
    );
  }
}