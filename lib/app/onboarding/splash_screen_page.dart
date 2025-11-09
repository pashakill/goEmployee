import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  // Fungsi untuk navigasi setelah 3 detik
  _navigateToOnboarding() async {
    await Future.delayed(const Duration(milliseconds: 3000)); // Jeda 3 detik

    // Pastikan widget masih ada (mounted) sebelum navigasi
    if (mounted) {
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