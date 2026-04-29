import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/model/add_data_cuti_model.dart';
import 'package:goemployee/kehadiran/slip_gaji/model/slip_gaji_response_model.dart';

class SlipGajiApi {
  final NetworkHelper network;

  SlipGajiApi({required this.network});

  // ================= GET LIST =================
  Future<SlipGajiResponseModel> getListSlipGaji({
    required String userId,
  }) async {
    try {
      final response = await network.get(
        "/slipgaji?user_id=$userId",
      );

      print("RAW RESPONSE: $response");
      print("TYPE: ${response.runtimeType}");

      final model = SlipGajiResponseModel.fromJson(
        Map<String, dynamic>.from(response),
      );

      print("SUCCESS MODEL: ${model.success}");
      print("DATA LENGTH: ${model.data.length}");

      return model;
    } catch (e) {
      print("ERROR PARSING: $e");
      rethrow;
    }
  }

  Future<SlipGajiResponseModel> uploadSlipGaji({
    required String userId,
    required String bulan,
    required String tahun,
    required String file
  }) async {
    try{
      final body = {
        "user_id": userId,
        "bulan": bulan,
        "tahun": tahun,
        "file": file,
      };
      final response = await network.post("/slipgaji/upload", body);
      if (response['success'] == true) {
        return SlipGajiResponseModel.fromJson(response);
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }



  Future<List<UserModel>> getListUser() async {
    try {
      final response = await network.get("/user"); // sudah Map
      if (response['success'] == true) {
        List data = response['data'];
        return data.map((e) => UserModel.fromJson(e)).toList();
      } else {
        throw ServerError(response['message']);
      }
    } on DioException catch (e) {
      throw mapDioError(e);
    }
  }
}