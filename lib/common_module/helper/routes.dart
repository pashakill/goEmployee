import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:goemployee/app/home/bloc/home_bloc.dart';
import 'package:goemployee/app/onboarding/onboarding.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/bloc/cuti_bloc.dart';
import 'package:goemployee/kehadiran/dinas_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/izin_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/kehadiran_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/persetujuan_page/bloc/bloc_persetujuan.dart';
import 'package:goemployee/kehadiran/wfh/bloc/bloc.dart';

import '../../kehadiran/lembur_page/bloc/lembur_bloc.dart';
import '../../kehadiran/slip_gaji/bloc/slip_gaji_bloc.dart';

class Routes {
  // Nama semua route (biar konsisten)
  static const String splashScreen = '/splashScreen';
  static const String home = '/home';
  static const String login = '/login';
  static const String loginKaryawan = '/$login/karyawan';

  static const String karyawan = '/karyawan';
  static const String kehadiranPage = '$karyawan/kehadiran';
  static const String cutiPage = '$karyawan/cuti_page';
  static const String tambahCutiPage = '$cutiPage/tambahCuti';
  static const String lemburPage = '$karyawan/lembur_page';
  static const String tambahLemburPage = '$lemburPage/tambahLembur';
  static const String dinasPage = '$karyawan/dinas_page';
  static const String tambahDinasPage = '$dinasPage/tambahDinas';
  static const String wfhPage = '$karyawan/wfh';
  static const String tambahWfh = '$wfhPage/tambahWfh';
  static const String izinPage = '$karyawan/izin_page';
  static const String tambahIzinPage = '$izinPage/tambahIzin';
  static const String persetujuanPage = '$karyawan/persetujuan_page';

  static const String presensiBackdatePage = '$karyawan/presensi_backdate_page';
  static const String tambahPresensiBackdatePage = '$presensiBackdatePage/tambahPresensi';

  static const String slipGajiPage = '$karyawan/slipGaji';


  // Daftar semua route
  static final pages = [
    GetPage(name: splashScreen, page: () => SplashScreen()),
    GetPage(name: home, page: () => BlocProvider(create: (context) => getIt<HomeBloc>(), child: HomePage())),
    GetPage(name: login, page: () => BlocProvider(create: (context) => getIt<LoginBloc>(), child: LoginPage())),
    GetPage(name: loginKaryawan, page: () => LoginKaryawanPage()),
    GetPage(name: kehadiranPage, page: () => BlocProvider(create: (context) => getIt<KehadiranBloc>(), child: KehadiranPage())),
    GetPage(name: cutiPage, page: () => CutiPage()),
    GetPage(name: lemburPage, page: () => LemburPage()),
    GetPage(name: tambahLemburPage, page: () => BlocProvider(create: (context) => getIt<LemburBloc>(), child: TambahLemburPage())),
    GetPage(name: dinasPage, page: () => DinasPage()),
    GetPage(name: presensiBackdatePage, page: () => PresensiBackdatePage()),
    GetPage(name: tambahDinasPage, page: () => BlocProvider(create: (context) => getIt<DinasBloc>(), child: TambahDinasPage())),
    GetPage(name: wfhPage, page: () => WfhPage()),
    GetPage(name: izinPage, page: () => IzinPage()),
    GetPage(name: slipGajiPage, page: () => BlocProvider(create: (context) => getIt<SlipGajiBloc>(), child: SlipGajiPage())),
    GetPage(name: persetujuanPage, page: () => BlocProvider(create: (context) => getIt<PersetujuanBloc>(), child: PersetujuanPage())),
    GetPage(name: tambahCutiPage, page: () => BlocProvider(create: (context) => getIt<CutiBloc>(), child: TambahCutiPage())),
    GetPage(name: tambahWfh, page: () => BlocProvider(create: (context) => getIt<WfhBloc>(), child: TambahWfhPage())),
    GetPage(name: tambahIzinPage, page: () => BlocProvider(create: (context) => getIt<IzinBloc>(), child: TambahIzinPage())),
    GetPage(name: tambahPresensiBackdatePage, page: () => BlocProvider(create: (context) => getIt<PresensiBackdateBloc>(), child: TambahPresensiBackdatePage())),
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
