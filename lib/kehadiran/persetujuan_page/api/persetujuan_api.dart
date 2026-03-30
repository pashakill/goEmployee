import 'package:goemployee/goemployee.dart';
import 'package:goemployee/user/user_view/auth/model/login_model.dart';

class PersetujuanApi {
  final NetworkHelper network;

  PersetujuanApi({required this.network});

  Future<DataCutiModel> getDataListPengajuan({required String userId, required String userRole, required String divisiId}) async {
    final response = await network.get('/pengajuan/approval?role=${userRole}&user_id=${userId}&divisi_id=${divisiId}',);
    if (response['success'] == true) {
      return DataCutiModel.fromJson(response);
    } else {
      throw Exception(response['message'] ?? "Gagal mengambil data");
    }
  }

  Future<DataCutiModel> approveDataPengajuan({required int pengajuan_id, required String role, required String action, required String divisi_id}) async {
    final response = await network.post("/approve", {
      "pengajuan_id": pengajuan_id,
      "role": role,
      "action": action,
      "divisi_id": divisi_id,
    });
    if (response['success'] == true) {
      return DataCutiModel.fromJson(response);
    } else {
      throw Exception(response['message'] ?? "Gagal mengambil data");
    }
  }
}
