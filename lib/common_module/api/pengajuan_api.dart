import 'package:dio/dio.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/cuti_page/model/add_data_cuti_model.dart';

class PengajuanApi {
  final NetworkHelper network;

  PengajuanApi({required this.network});

  // ================= GET LIST =================
  Future<DataCutiModel> getList({
    required String userId,
    PengajuanKategori? kategori,
  }) async {
    try{
      final body = {
        "user_id": userId,
        if (kategori != null) "kategori": kategori.value,
      };

      final response = await network.get("/pengajuan/list", data: body);

      if (response['success'] == true) {
        return DataCutiModel.fromJson(response);
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }

  // ================= ADD PENGAJUAN =================
  Future<AddDataCutiModel> addPengajuan({
    required String userId,
    required PengajuanKategori kategori,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? jamMulai,
    String? jamSelesai,
    int? lama,
    String? alamat,
    String? latitude,
    String? longitude,
    String? alasan,
    String? berkas,
    String? izinKategori,
    String? jamIzin,
    String? cuti_kategori,
  }) async {
    try{
      final body = {
        "user_id": userId,
        "kategori": kategori.value,
        "tanggal_mulai": tanggalMulai,
        "tanggal_selesai": tanggalSelesai,
        "jam_mulai": jamMulai,
        "jam_selesai": jamSelesai,
        "lama": lama,
        "latitude": latitude,
        "longitude": longitude,
        "alasan": alasan ?? "",
        "berkas": berkas ?? "",
        "izin_kategori": izinKategori,
        "jam_izin": jamIzin,
        "alamat": alamat,
        "cuti_kategori": cuti_kategori,
      };

      final response = await network.post("/pengajuan/buat", body);
      if (response['success'] == true) {
        return AddDataCutiModel.fromJson(response);
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }

  Future<AddDataCutiModel> editPengajuan({
    required String pengajuanId,
    required String userId,
    required PengajuanKategori kategori,
    required String tanggalMulai,
    required String tanggalSelesai,
    String? jamMulai,
    String? jamSelesai,
    int? lama,
    String? alamat,
    String? latitude,
    String? longitude,
    String? alasan,
    String? berkas,
    String? izinKategori,
    String? jamIzin,
    String? cuti_kategori,
  }) async {
    try{
      final body = {
        "user_id": userId,
        "id": pengajuanId,
        "kategori": kategori.value,
        "tanggal_mulai": tanggalMulai,
        "tanggal_selesai": tanggalSelesai,
        "jam_mulai": jamMulai,
        "jam_selesai": jamSelesai,
        "lama": lama,
        "latitude": latitude,
        "longitude": longitude,
        "alasan": alasan ?? "",
        "berkas": berkas ?? "",
        "izin_kategori": izinKategori,
        "jam_izin": jamIzin,
        "alamat": alamat,
        "cuti_kategori": cuti_kategori,
      };

      final response = await network.post("/pengajuan/update", body);
      if (response['success'] == true) {
        return AddDataCutiModel.fromJson(response);
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }

  Future<bool> hapusPengajuan({
    required String pengajuanId,
    required String userId,
  }) async {
    try{
      final body = {
        "user_id": userId,
        "id": pengajuanId,
      };

      final response = await network.post("/pengajuan/delete", body);
      if (response['success'] == true) {
        return true;
      } else {
        throw ServerError(null);
      }
    }on DioException catch(e){
      throw mapDioError(e);
    }
  }
}