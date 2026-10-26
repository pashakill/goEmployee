
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
    required this.details,
  });

  factory AbsensiSummaryResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {

    final data =
    Map<String, dynamic>.from(
      json['data'] ?? {},
    );

    return AbsensiSummaryResponseModel(

      success:
      json['success'] ?? false,

      message:
      json['message'] ?? '',

      summary:
      AbsensiSummaryModel.fromJson(
        Map<String, dynamic>.from(
          data['summary'] ?? {},
        ),
      ),

      details: (data['details'] as List? ?? [])
          .map(
            (e) => AbsensiDetailItem.fromJson(
          Map<String, dynamic>.from(e),
        ),
      )

          .toList(),
    );
  }
}