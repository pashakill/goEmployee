
import 'package:goemployee/goemployee.dart';

class AbsensiSummaryResponseModel {
  final bool success;
  final String message;
  final AbsensiSummaryModel summary;
  final List<AbsensiDetailItem> details;


  AbsensiSummaryResponseModel({
    required this.success,
    required this.message,
    required this.summary,
    required this.details
  });

  factory AbsensiSummaryResponseModel.fromJson(Map<String, dynamic> json) {
    return AbsensiSummaryResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      summary: AbsensiSummaryModel.fromJson(json['summary']),
      details: (json['details'] as List<dynamic>)
          .map((e) => AbsensiDetailItem.fromJson(e))
          .toList(),
    );
  }
}