import 'dart:convert';

import 'package:dio/dio.dart';

// ===== ERROR TYPE =====
abstract class NetworkError {
  final String message;
  NetworkError(this.message);
}

class NoInternetError extends NetworkError {
  NoInternetError() : super("Tidak ada koneksi internet");
}

class TimeoutError extends NetworkError {
  TimeoutError() : super("Koneksi timeout");
}

class ServerError extends NetworkError {
  final int? code;

  ServerError(this.code, String message)
      : super(message);
}

class UnknownError extends NetworkError {
  UnknownError([String message = "Terjadi kesalahan"]) : super(message);
}

// ===== MAPPER =====
NetworkError mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
      return NoInternetError();

    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutError();

    case DioExceptionType.sendTimeout:
      return TimeoutError();

    case DioExceptionType.badResponse:
    /// 🔥 AMBIL MESSAGE BACKEND
      final message = getDioErrorMessage(e);
      print('errorr disini DIO EXCEPTION ${e.message}');
      return ServerError(
        e.response?.statusCode,
        message,
      );

    case DioExceptionType.unknown:
      if (e.message != null &&
          e.message!.contains('SocketException')) {
        return NoInternetError();
      }
      return UnknownError();

    default:
      return UnknownError();
  }
}

String getDioErrorMessage(DioException e) {
  final responseData = e.response?.data;

  if (responseData == null) {
    return e.message ?? "Server error";
  }

  // Jika response sudah berbentuk Map
  if (responseData is Map<String, dynamic>) {
    return responseData['message']?.toString() ?? "Server error";
  }

  // Jika response Map tapi belum typed
  if (responseData is Map) {
    return responseData['message']?.toString() ?? "Server error";
  }

  // Jika response masih berbentuk String JSON
  if (responseData is String) {
    try {
      final decoded = jsonDecode(responseData);

      if (decoded is Map) {
        return decoded['message']?.toString() ?? responseData;
      }

      return responseData;
    } catch (_) {
      return responseData;
    }
  }

  return e.message ?? "Server error";
}