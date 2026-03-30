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
  ServerError(this.code) : super("Server error ($code)");
}

class UnknownError extends NetworkError {
  UnknownError() : super("Terjadi kesalahan");
}

// ===== MAPPER =====
NetworkError mapDioError(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionError:
      return NoInternetError();
    case DioExceptionType.connectionTimeout:
      return NoInternetError();
    case DioExceptionType.receiveTimeout:
      return NoInternetError();
    case DioExceptionType.sendTimeout:
      return TimeoutError();

    case DioExceptionType.badResponse:
      return ServerError(e.response?.statusCode);

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