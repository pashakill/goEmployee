// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModels _$LoginResponseFromJson(Map<String, dynamic> json) => UserModels(
  json['id'] as int,
  json['nama'] as String,
  json['username'] as String,
  json['password'] as String,
  json['company_name'] as String,
  json['role'] as String,
  json['date_now'] as String,
  json['time_checkin'] as String?,
  json['time_checkout'] as String?,
  json['late_checkin'] as String?,
  json['photo'] as String?,
  json['jadwal_mulai_kerja'] as String?,
  json['jadwal_selesai_kerja'] as String?,

  json['latitude'] as String?,
  json['longitude'] as String?,
  json['radius'] as String?,
);

Map<String, dynamic> _$LoginResponseToJson(UserModels instance) => <String, dynamic>{
  'id': instance.id,
  'nama': instance.nama,
  'username': instance.username,
  'password': instance.password,
  'company_name': instance.companyName,
  'role': instance.role,
  'date_now': instance.dateNow,
  'time_checkin': instance.timeCheckin,
  'time_checkout': instance.timeCheckout,
  'late_checkin': instance.lateCheckin,
  'photo': instance.photo,
  'jadwal_mulai_kerja': instance.jadwalMulaiKerja,
  'jadwal_selesai_kerja': instance.jadwalSelesaiKerja,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'radius': instance.radius,
};
