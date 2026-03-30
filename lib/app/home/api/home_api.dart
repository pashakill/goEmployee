import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/model/add_data_cuti_model.dart';

class HomeApi {
  final NetworkHelper network;

  HomeApi({required this.network});

  // ================= GET LIST =================
  Future<NotificationModel> getListNotification({
    required String userId,
    PengajuanKategori? kategori,
  }) async {
    try{
      final body = {
        "user_id": userId,
      };
      final response = await network.get("/notification", data: body);
      if (response['success'] == true) {
        return NotificationModel.fromJson(response);
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }
}