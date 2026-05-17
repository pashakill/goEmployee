
class AbsensiSummaryModel {
  final int totalLateMinutes;
  final int totalLateHours;

  AbsensiSummaryModel({
    required this.totalLateMinutes,
    required this.totalLateHours,
  });

  factory AbsensiSummaryModel.fromJson(Map<String, dynamic> json) {
    return AbsensiSummaryModel(
      totalLateMinutes: (json['total_late_minutes'] ?? 0) as int,
      totalLateHours: (json['total_late_hours'] ?? 0) as int,
    );
  }
}