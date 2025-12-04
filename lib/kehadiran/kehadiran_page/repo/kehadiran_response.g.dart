// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kehadiran_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KehadiranResponseModel _$KehadiranResponseFromJson(Map<String, dynamic> json) => KehadiranResponseModel(
  json['tanggal'] as String? ?? '',
  json['jam_masuk'] as String? ?? '',
  json['terlambat'] as String? ?? '',
  json['latitude'] as String? ?? '',
  json['longitude'] as String? ?? '',
);

Map<String, dynamic> _$KehadiranResponseToJson(KehadiranResponseModel instance) =>
    <String, dynamic>{
      'tanggal': instance.tanggal,
      'jam_masuk': instance.jamMasuk,
      'terlambat': instance.terlambat,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
