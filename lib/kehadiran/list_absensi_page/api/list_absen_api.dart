import 'package:goemployee/goemployee.dart';

class ListAbsenApi {
  final NetworkHelper network;

  ListAbsenApi({required this.network});

  // ================= GET LIST =================
  Future<AbsensiResponseModel> getListAbsen({
    String? status,
    String? userId,
    String? from,
    String? to,
  }) async {
    try {
      String url = "/absen/list";

      List<String> query = [];
      if (status != null) query.add("status=$status");
      if (userId != null) query.add("user_id=$userId");
      if (from != null) query.add("from=$from");
      if (to != null) query.add("to=$to");

      if (query.isNotEmpty) {
        url += "?${query.join("&")}";
      }

      final response = await network.get(url);

      final model = AbsensiResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      return model;
    } catch (e) {
      rethrow;
    }
  }

  Future<AbsensiSummaryResponseModel> getSummaryUser({
    String? userId,
    String? from,
    String? to,
  }) async {
    try {
      String url = "/absensi/user-summary";

      List<String> query = [];
      if (userId != null) query.add("user_id=$userId");
      if (from != null) query.add("from=$from");
      if (to != null) query.add("to=$to");

      if (query.isNotEmpty) {
        url += "?${query.join("&")}";
      }

      final response = await network.get(url);

      final model = AbsensiSummaryResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      return model;
    } catch (e) {
      rethrow;
    }
  }
}