


import 'package:goemployee/user/user_view/auth/model/user_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'pengajuan_response.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class PengajuanData {

  final int id;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String jam_mulai;
  final String jam_selesai;
  final String lama;
  final String latitude;
  final String longitude;
  final String alasan;
  final String berkas;
  final String izin_kategori;
  final String jam_izin;
  final String status_manager;
  final String status_hrd;
  final String created_at;


  PengajuanData(this.id, this.kategori, this.tanggal_mulai, this.tanggal_selesai, this.jam_mulai,
      this.jam_selesai, this.lama, this.latitude, this.longitude, this.alasan,
      this.berkas, this.izin_kategori, this.jam_izin, this.status_manager, this.status_hrd,
      this.created_at);

  factory PengajuanData.fromJson(Map<String, dynamic> json) =>
      _$CutiResponseFromJson(json);

  Map<String, dynamic> toJson() => _$CutiResponseToJson(this);

  @override
  String toString() {
    return 'LoginModel(id: $id, kategori: "$kategori", tanggal_mulai: $tanggal_mulai, '
        'tanggal_selesai: $tanggal_selesai, jam_mulai: $jam_mulai, jam_selesai: $jam_selesai, '
        'lama: $lama, latitude: $latitude, longitude: $longitude, alasan: $alasan, '
        'berkas: $berkas, izin_kategori: $izin_kategori, jam_izin: $jam_izin, '
        'status_manager: $status_manager, status_hrd: $status_hrd, created_at: $created_at'
        ')';
  }
}