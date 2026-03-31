import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'dio_error_mapper.dart';

// Ganti dengan IP PC/Laptop tempat server Dart berjalan
const String _baseUrl = 'http://192.168.76.159:8080';
const String _apiKey = 'RAHASIA123456';

class NetworkHelper {
  final Dio _dio;

  NetworkHelper()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15), // Timeout lebih aman untuk HP
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'x-api-key': _apiKey,
      'Content-Type': 'application/json',
    },
  )) {
    // Logging untuk debug
    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      compact: false,
    ));
  }

  // -------------------
  // POST GENERIK
  // -------------------
  Future<Map<String, dynamic>> post(String endpoint,
      Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }

  // -------------------
  // GET GENERIK
  // -------------------
  Future<Map<String, dynamic>> get(String endpoint,
      {Map<String, dynamic>? data}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}