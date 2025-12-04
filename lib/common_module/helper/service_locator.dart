import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/bloc/cuti_bloc.dart';
import 'package:goemployee/kehadiran/kehadiran_page/bloc/bloc.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // 1. Singleton Network Helper
  getIt.registerLazySingleton<NetworkHelper>(() => NetworkHelper());

  // 2. Repository
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(network: getIt<NetworkHelper>()),);
  getIt.registerLazySingleton<KehadiranApi>(() => KehadiranApi(network: getIt<NetworkHelper>()),);
  getIt.registerLazySingleton<CutiApi>(() => CutiApi(network: getIt<NetworkHelper>()),);

  // 3. BLoC
  getIt.registerFactory<LoginBloc>(() => LoginBloc(authApi: getIt<AuthApi>()),);
  getIt.registerFactory<KehadiranBloc>(() => KehadiranBloc(kehadiranApi: getIt<KehadiranApi>()),);
  getIt.registerFactory<CutiBloc>(() => CutiBloc(cutiApi: getIt<CutiApi>()),);
}
