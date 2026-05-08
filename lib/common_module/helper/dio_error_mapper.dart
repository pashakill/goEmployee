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
      final message =
          e.response?.data?['message'] ??
              e.error?.toString() ??
              "Server error";

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