
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Mengelola sesi login pengguna dengan aman menggunakan FlutterSecureStorage.
///
/// Kelas ini menangani penyimpanan, pengambilan, dan penghapusan
/// ID pengguna yang sedang login.
class SessionManager {
  /// Instance privat dari FlutterSecureStorage.
  final _secureStorage = const FlutterSecureStorage();

  /// Kunci (key) yang digunakan untuk menyimpan ID pengguna di Secure Storage.
  /// Sebaiknya privat agar tidak bisa diakses dari luar kelas ini.
  static const String _sessionKey = 'current_user_id';

  /// Menyimpan ID pengguna ke Secure Storage.
  ///
  /// Panggil fungsi ini saat pengguna berhasil login.
  Future<void> saveSession(String userId) async {
    try {
      await _secureStorage.write(key: _sessionKey, value: userId);
      print('SessionManager: Sesi untuk user $userId berhasil disimpan.');
    } catch (e) {
      print('SessionManager: Gagal menyimpan sesi - $e');
    }
  }

  /// Mengambil ID pengguna yang tersimpan dari Secure Storage.
  ///
  /// Mengembalikan `String` berisi ID pengguna jika ada,
  /// atau `null` jika tidak ada sesi (pengguna belum login).
  Future<String?> getSession() async {
    try {
      final String? userId = await _secureStorage.read(key: _sessionKey);
      if (userId != null && userId.isNotEmpty) {
        print('SessionManager: Sesi ditemukan (User ID: $userId).');
        return userId;
      } else {
        print('SessionManager: Sesi tidak ditemukan.');
        return null;
      }
    } catch (e) {
      print('SessionManager: Gagal membaca sesi - $e');
      return null;
    }
  }

  /// Menghapus ID pengguna dari Secure Storage.
  ///
  /// Panggil fungsi ini saat pengguna logout.
  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _sessionKey);
      print('SessionManager: Sesi berhasil dihapus.');
    } catch (e) {
      print('SessionManager: Gagal menghapus sesi - $e');
    }
  }

  /// Pengecekan cepat apakah pengguna memiliki sesi aktif.
  ///
  /// Mengembalikan `true` jika ID pengguna tersimpan, `false` jika tidak.
  Future<bool> isLoggedIn() async {
    final session = await getSession();
    return session != null;
  }
}


///UNTUK LOGOUT
///// 1. Buat instance
// final SessionManager _sessionManager = SessionManager();
//
// // ... di dalam tombol logout ...
// onPressed: () async {
//   // 2. Hapus sesi
//   await _sessionManager.clearSession();
//
//   // 3. Navigasi kembali ke LoginPage
//   Navigator.pushReplacement(context, ...);
// }


///checklogin
///// 1. Buat instance
// final SessionManager _sessionManager = SessionManager();
//
// // ... di dalam initState() atau fungsi pengecekan ...
// void _checkLogin() async {
//   // 2. Ambil sesi
//   String? userId = await _sessionManager.getSession();
//
//   if (userId != null) {
//     // Pengguna sudah login, arahkan ke HomePage
//   } else {
//     // Pengguna belum login, arahkan ke LoginPage
//   }
// }