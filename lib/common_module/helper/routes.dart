import 'package:get/get.dart';
import 'package:goemployee/goemployee.dart';

class Routes {
  // Nama semua route (biar konsisten)
  static const String home = '/home';
  static const String login = '/login';
  static const String loginKaryawan = '/$login/karyawan';

  static const String karyawan = '/karyawan';
  static const String kehadiranPage = '$karyawan/kehadiran';
  static const String cutiPage = '$karyawan/cuti';
  static const String tambahCutiPage = '$cutiPage/tambahCuti';
  static const String lemburPage = '$karyawan/lembur';
  static const String tambahLemburPage = '$lemburPage/tambahLembur';
  static const String dinasPage = '$karyawan/dinas';
  static const String tambahDinasPage = '$dinasPage/tambahDinas';
  static const String wfhPage = '$karyawan/wfh';
  static const String izinPage = '$karyawan/izin';
  static const String persetujuanPage = '$karyawan/persetujuan';


  // Daftar semua route
  static final pages = [
    GetPage(name: home, page: () => HomePage()),
    GetPage(name: login, page: () => LoginPage()),
    GetPage(name: loginKaryawan, page: () => LoginKaryawanPage()),
    GetPage(name: kehadiranPage, page: () => KehadiranPage()),
    GetPage(name: cutiPage, page: () => CutiPage()),
    GetPage(name: lemburPage, page: () => LemburPage()),
    GetPage(name: tambahLemburPage, page: () => TambahLemburPage()),
    GetPage(name: dinasPage, page: () => DinasPage()),
    GetPage(name: tambahDinasPage, page: () => TambahDinasPage()),
    GetPage(name: wfhPage, page: () => WfhPage()),
    GetPage(name: izinPage, page: () => IzinPage()),
    GetPage(name: persetujuanPage, page: () => PersetujuanPage()),
    GetPage(name: tambahCutiPage, page: () => TambahCutiPage()),

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
