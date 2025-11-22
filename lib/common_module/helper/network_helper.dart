import 'package:dio/dio.dart';

// Ganti dengan IP PC/Laptop tempat server Dart berjalan
const String _baseUrl = 'http://192.168.76.245:8080';
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
    _dio.interceptors.add(LogInterceptor(
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
    ));
  }

  // -------------------
  // POST GENERIK
  // -------------------
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(endpoint, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw NetworkException('Terjadi error tidak terduga: ${e.toString()}');
    }
  }

  // -------------------
  // GET GENERIK
  // -------------------
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    try {
      final response = await _dio.get(endpoint, queryParameters: queryParams);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw NetworkException(_handleDioError(e));
    } catch (e) {
      throw NetworkException('Terjadi error tidak terduga: ${e.toString()}');
    }
  }

  // -------------------
  // ERROR HANDLER
  // -------------------
  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'Koneksi timeout. Cek koneksi internet Anda.';
    }

    if (e.type == DioExceptionType.badResponse) {
      if (e.response?.data != null && e.response!.data is Map) {
        return e.response!.data['message'] ?? 'Error: ${e.response!.statusCode}';
      }
      return 'Error: ${e.response?.statusCode}';
    }

    if (e.type == DioExceptionType.cancel) {
      return 'Permintaan ke server dibatalkan.';
    }

    return 'Koneksi gagal. Cek koneksi internet Anda.';
  }
}

// -------------------
// EXCEPTION
// -------------------
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => message;
}
