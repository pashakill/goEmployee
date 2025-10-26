import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';

class Routes {
  // Nama semua route (biar konsisten)
  static const String home = '/home';
  static const String login = '/login';
  static const String loginKaryawan = '/$login/karyawan';

  // Daftar semua route
  static final pages = [
    GetPage(name: home, page: () => const HomePage()),
    GetPage(name: login, page: () => const LoginPage()),
  ];
}

class AppNavigator {
  /// Pindah ke halaman lain (tanpa menghapus halaman sebelumnya)
  static void to(String routeName, {dynamic arguments}) {
    Get.toNamed(routeName, arguments: arguments);
  }

  /// Ganti halaman saat ini (hapus halaman sebelumnya)
  static void off(String routeName, {dynamic arguments}) {
    Get.offNamed(routeName, arguments: arguments);
  }

  /// Pindah ke halaman baru dan hapus semua halaman sebelumnya
  static void offAll(String routeName, {dynamic arguments}) {
    Get.offAllNamed(routeName, arguments: arguments);
  }

  /// Kembali ke halaman sebelumnya
  static void back() {
    Get.back();
  }
}
