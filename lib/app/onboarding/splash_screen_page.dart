import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  final SessionManager _sessionManager = SessionManager();
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final MobileSecurityChecker _security = MobileSecurityChecker();

  @override
  void initState() {
    super.initState();
    _checkSessionAndNavigate();
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

  Future<void> _checkSessionAndNavigate() async {
    // Beri jeda 1-2 detik agar logo terlihat
    await Future.delayed(const Duration(seconds: 2));

    try {
      final isRooted = await _security.isRooted();

      if (isRooted) {
        _showBlockDialog();
        return;
      }

      // 1. Mencoba mengambil ID user dari secure storage
      final String? userIdString = await _sessionManager.getSession();
      // -----------------------------

      if (userIdString != null) {
        // 2. SESI DITEMUKAN
        //    Sekarang, validasi ID ini ke database
        final int userId = int.parse(userIdString);
        final User? user = await _dbHelper.getUserById(userId);

        if (user != null) {
          // 3. VALIDASI SUKSES (User ada di database)
          //    Arahkan ke HomePage
          print("SplashScreen: Sesi valid. Navigasi ke Home.");
          AppNavigator.offAll(Routes.home);
        } else {
          // 4. VALIDASI GAGAL (Sesi invalid, user tidak ada di DB)
          //    Hapus sesi buruk dan arahkan ke Login
          print("SplashScreen: Sesi invalid. Navigasi ke Login.");
          await _sessionManager.clearSession();
          AppNavigator.offAll(Routes.login);
        }
      } else {
        // 5. SESI TIDAK DITEMUKAN
        //    Arahkan ke LoginPage
        print("SplashScreen: Sesi tidak ditemukan. Navigasi ke Login.");
        AppNavigator.offAll(Routes.login);
      }
    } catch (e) {
      // 6. TERJADI ERROR (Misal: DB error, parsing ID gagal)
      //    Selalu aman untuk menghapus sesi dan ke Login
      print("SplashScreen: Error validasi. $e");
      await _sessionManager.clearSession();
      AppNavigator.offAll(Routes.login);
    }
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Security Alert"),
        content: const Text(
          "Device root/jailbreak terdeteksi.\nAplikasi tidak dapat digunakan.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              // optional: keluar paksa
              Navigator.of(context).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      // Tampilkan logo dan teks di tengah layar
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(
          20,
          30,
          20,
          30,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F9D58),
              Color(0xFF34A853),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
       child: Center(
         child: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             Container(
               padding: const EdgeInsets.all(10),
               decoration: BoxDecoration(
                 color: Colors.white
                     .withOpacity(0.15),
                 borderRadius:
                 BorderRadius.circular(16),
               ),

               child: const Icon(
                 Icons.business_center_rounded,
                 color: Colors.white,
                 size: 28,
               ),
             ),

             const SizedBox(width: 12),

             const Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 Text(
                   "GoEmployee",
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 18,
                     fontWeight:
                     FontWeight.bold,
                   ),
                 ),
                 SizedBox(height: 2),
                 Text(
                   "Employee Management",
                   style: TextStyle(
                     color: Colors.white70,
                     fontSize: 11,
                   ),
                 ),
               ],
             ),
           ],
         ),
       ),
      )
    );
  }
}