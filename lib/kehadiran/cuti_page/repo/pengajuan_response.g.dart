// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pengajuan_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PengajuanData _$CutiResponseFromJson(Map<String, dynamic> json) => PengajuanData(
  json['id'] as int,
  json['kategori'] as String? ?? '',
  json['tanggal_mulai'] as String? ?? '',
  json['tanggal_selesai'] as String? ?? '',
  json['jam_mulai'] as String? ?? '',
  json['jam_selesai'] as String? ?? '',
  json['lama'] as String? ?? '',
  json['latitude'] as String? ?? '',
  json['longitude'] as String? ?? '',
  json['alasan'] as String? ?? '',
  json['berkas'] as String? ?? '',
  json['izin_kategori'] as String? ?? '',
  json['jam_izin'] as String? ?? '',
  json['status_manager'] as String? ?? '',
  json['status_hrd'] as String? ?? '',
  json['created_at'] as String? ?? '',
);

Map<String, dynamic> _$CutiResponseToJson(PengajuanData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kategori': instance.kategori,
      'tanggal_mulai': instance.tanggal_mulai,
      'tanggal_selesai': instance.tanggal_selesai,
      'jam_mulai': instance.jam_mulai,
      'jam_selesai': instance.jam_selesai,
      'lama': instance.lama,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'alasan': instance.alasan,
      'berkas': instance.berkas,
      'izin_kategori': instance.izin_kategori,
      'jam_izin': instance.jam_izin,
      'status_manager': instance.status_manager,
      'status_hrd': instance.status_hrd,
      'created_at': instance.created_at,
    };


