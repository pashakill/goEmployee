
import 'absensi_model.dart';

class AbsensiResponseModel {
  final bool success;
  final String message;
  final List<AbsensiModel> data;

  AbsensiResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory AbsensiResponseModel.fromJson(Map<String, dynamic> json) {
    return AbsensiResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>)
          .map((e) => AbsensiModel.fromJson(e))
          .toList(),
    );
  }
}