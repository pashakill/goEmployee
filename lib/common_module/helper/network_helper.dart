import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'dio_error_mapper.dart';

// Ganti dengan IP PC/Laptop tempat server Dart berjalan
const String _baseUrl = 'https://goemployee.kopiku.site';
const String _apiKey = 'RAHASIA123456';

class NetworkHelper {
  final Dio _dio;

  NetworkHelper()
      : _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'x-api-key': _apiKey,
      'Content-Type': 'application/json',
    },
  )) {

    /// 🔥 GLOBAL INTERCEPTOR
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          return handler.next(options);
        },

        onResponse: (response, handler) {
          final data = response.data;
          if (data is Map && data['success'] == false) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                type: DioExceptionType.badResponse,
                error: data['message'], // ← ambil message backend
              ),
            );
          }

          return handler.next(response);
        },

        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: false, // Sembunyikan header API key
        requestBody: false,   // Sembunyikan password request
        responseBody: true,   // Tampilkan response backend
        responseHeader: false,
        compact: false,
      ),
    );
  }

  // -------------------
  // POST GENERIK
  // -------------------
  Future<Map<String, dynamic>> post(
      String endpoint,
      Map<String, dynamic> data,
      ) async {
    try {
      final response = await _dio.post(endpoint, data: data);

      debugPrint('API STATUS: ${response.statusCode}');
      debugPrint('API RESPONSE: ${response.data}');

      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      debugPrint('API ERROR TYPE: ${e.type}');
      debugPrint('API ERROR MESSAGE: ${e.message}');
      debugPrint('API HTTP STATUS: ${e.response?.statusCode}');
      debugPrint('API ERROR RESPONSE: ${e.response?.data}');

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