import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/model/add_data_cuti_model.dart';
import 'package:goemployee/user/user_view/auth/model/login_model.dart';

class CutiApi {
  final NetworkHelper network;

  CutiApi({required this.network});

  Future<DataCutiModel> getListCuti(String userId) async {
    final response = await network.get("/pengajuan/list", data: {
      "user_id": userId,
    });
    if (response['success'] == true) {
      return DataCutiModel.fromJson(response);;
    } else {
      throw Exception(response['message'] ?? "Gagal mengambil data cuti");
    }
  }

  Future<AddDataCutiModel> addCuti(String userId, String jenis_cuti,
      String tanggal_mulai, String tanggal_selesai, String _alasan, String _dokumen, CutiModel cutiModel) async {
    final response = await network.post("/pengajuan/buat",
        {
          "user_id": userId,
          "kategori": jenis_cuti,
          "tanggal_mulai": tanggal_mulai,
          "tanggal_selesai": tanggal_selesai,
          "alasan": _alasan ?? "",
          "berkas": _dokumen ?? "",
        });
    if (response['success'] == true) {
      return AddDataCutiModel.fromJson(response);
    } else {
      throw Exception(response['message'] ?? "Gagal mengambil data cuti");
    }
  }
}
