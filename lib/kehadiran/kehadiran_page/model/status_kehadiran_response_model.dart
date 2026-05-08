
import 'package:goemployee/kehadiran/kehadiran_page/model/status_kehadiran_model.dart';

class StatusKehadiranResponseModel {
  final bool success;
  final String message;
  final StatusKehadiranModel data;

  StatusKehadiranResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory StatusKehadiranResponseModel.fromJson(Map<String, dynamic> json) {
    return StatusKehadiranResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: StatusKehadiranModel.fromJson(json['data']),
    );
  }
}