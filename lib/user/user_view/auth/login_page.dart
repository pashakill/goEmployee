import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // State untuk mengelola visibilitas password
  bool _isPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // --- 1. Background Gradient yang Menarik ---
        // Menggunakan gradien diagonal dari hijau tua ke hijau lebih terang
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
        child: Center(
          // --- 2. SingleChildScrollView ---
          // Agar form tidak terpotong saat keyboard muncul
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // --- 3. Logo atau Judul ---
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
                const Text(
                  'Silakan login untuk melanjutkan',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),

                // --- 4. Form Card (Efek Kaca) ---
                // Menggunakan container dengan padding dan margin
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24.0),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    // Warna putih transparan untuk efek "glassmorphism"
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16.0),
                    // Border tipis untuk mempertegas
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      // --- 5. Input Field Employee ID ---
                      _buildTextField(
                        label: 'Employee ID',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),

                      // --- 6. Input Field Password ---
                      _buildPasswordField(),
                      const SizedBox(height: 32),

                      // --- 7. Tombol Login ---
                      _buildLoginButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Input Field ---
  Widget _buildTextField({required String label, required IconData icon}) {
    return TextField(
      style: const TextStyle(color: Colors.white), // Warna teks input
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        // Garis bawah saat tidak aktif
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        // Garis bawah saat aktif (di-fokus)
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Password Field ---
  Widget _buildPasswordField() {
    return TextField(
      style: const TextStyle(color: Colors.white), // Warna teks input
      obscureText: !_isPasswordVisible, // Sembunyikan/tampilkan password
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
        // Tombol untuk toggle visibilitas
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2),
        ),
      ),
    );
  }

  // --- Widget Helper untuk Tombol Login ---
  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // Warna tombol putih
          foregroundColor: Colors.green.shade800, // Warna teks hijau tua
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
        ),
        onPressed: () {
          AppNavigator.offAll(Routes.home);
        },
        child: const Text(
          'LOGIN',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}