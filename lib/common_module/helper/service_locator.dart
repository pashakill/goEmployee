import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/bloc/cuti_bloc.dart';
import 'package:goemployee/kehadiran/dinas_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/izin_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/kehadiran_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/lembur_page/bloc/bloc.dart';
import 'package:goemployee/kehadiran/persetujuan_page/api/api.dart';
import 'package:goemployee/kehadiran/wfh/bloc/bloc.dart';

import '../../kehadiran/persetujuan_page/bloc/persetujuan_bloc.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // 1. Singleton Network Helper
  getIt.registerLazySingleton<NetworkHelper>(() => NetworkHelper());

  // 2. Repository
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(network: getIt<NetworkHelper>()),);
  getIt.registerLazySingleton<KehadiranApi>(() => KehadiranApi(network: getIt<NetworkHelper>()),);
  getIt.registerLazySingleton<PengajuanApi>(() => PengajuanApi(network: getIt<NetworkHelper>()),);
  getIt.registerLazySingleton<PersetujuanApi>(() => PersetujuanApi(network: getIt<NetworkHelper>()),);

  // 3. BLoC
  getIt.registerFactory<LoginBloc>(() => LoginBloc(authApi: getIt<AuthApi>()));
  getIt.registerFactory<KehadiranBloc>(() => KehadiranBloc(kehadiranApi: getIt<KehadiranApi>()));
  getIt.registerFactory<CutiBloc>(() => CutiBloc(pengajuanApi: getIt<PengajuanApi>()));
  getIt.registerFactory<LemburBloc>(() => LemburBloc(pengajuanApi: getIt<PengajuanApi>()));
  getIt.registerFactory<DinasBloc>(() => DinasBloc(pengajuanApi: getIt<PengajuanApi>()));
  getIt.registerFactory<WfhBloc>(() => WfhBloc(pengajuanApi: getIt<PengajuanApi>()));
  getIt.registerFactory<IzinBloc>(() => IzinBloc(pengajuanApi: getIt<PengajuanApi>()));
  getIt.registerFactory<PersetujuanBloc>(() => PersetujuanBloc(persetujuanApi: getIt<PersetujuanApi>()));

}
