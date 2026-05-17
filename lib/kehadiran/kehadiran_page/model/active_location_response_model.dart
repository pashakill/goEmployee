import 'package:goemployee/goemployee.dart';

class ActiveLocationResponseModel {
  final bool success;
  final String message;
  final ActiveLocationModel? data;

  ActiveLocationResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory ActiveLocationResponseModel.fromJson(Map<String, dynamic> json) {
    return ActiveLocationResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ActiveLocationModel.fromJson(json['data'])
          : null,
    );
  }
}