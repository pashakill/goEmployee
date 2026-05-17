import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';

class KehadiranApi {
  final NetworkHelper network;

  KehadiranApi({required this.network});

  Future<KehadiranModel> checkIn({required String user_id, required String latitude, required String longitude}) async {
    try{
      final response = await network.post("/absen/checkin", {
        "user_id": user_id,
        "latitude": latitude,
        "longitude": longitude
      });
      return KehadiranModel.fromJson(response);
    }on DioException catch(e){
      print('kena disini DioException');
      throw mapDioError(e);
    }
  }

  Future<StatusKehadiranResponseModel> getStatusAbsen({
    String? userId,
  }) async {
    try {
      String url = "/status-kehadiran";
      List<String> query = [];
      if (userId != null) query.add("user_id=$userId");
      if (query.isNotEmpty) {
        url += "?${query.join("&")}";
      }
      final response = await network.get(url);
      final model = StatusKehadiranResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<ActiveLocationResponseModel> getActiveLocation({
    String? userId,
  }) async {
    try {
      String url = "/active-location";
      List<String> query = [];
      if (userId != null) query.add("user_id=$userId");
      if (query.isNotEmpty) {
        url += "?${query.join("&")}";
      }
      final response = await network.get(url);
      final model = ActiveLocationResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );
      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<KehadiranModel> checkout({
    required String userId,
    required String longitude,
    required String latitude,
  }) async {
    try{
      final response = await network.post("/absen/checkout", {
        "user_id": userId,
        "latitude": latitude,
        "longitude": longitude
      });
      return KehadiranModel.fromJson(response);
    }on DioException catch(e){
      print('kena disini DioException');
      throw mapDioError(e);
    }
  }
}
