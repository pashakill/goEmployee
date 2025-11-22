import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';

final getIt = GetIt.instance;

void setupLocator() {
  // 1. Singleton Network Helper
  getIt.registerLazySingleton<NetworkHelper>(() => NetworkHelper());

  // 2. Auth Repository
  getIt.registerLazySingleton<AuthApi>(() => AuthApi(network: getIt<NetworkHelper>()),);

  // 3. Login BLoC
  getIt.registerFactory<LoginBloc>(() => LoginBloc(authApi: getIt<AuthApi>()),);
}
