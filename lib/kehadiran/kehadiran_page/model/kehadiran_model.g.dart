// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kehadiran_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KehadiranModel _$KehadiranModelFromJson(Map<String, dynamic> json) => KehadiranModel(
  json['data'] != null
      ? KehadiranResponseModel.fromJson(json['data'] as Map<String, dynamic>)
      : null,
  json['message'] as String? ?? '',
  json['success'] as bool? ?? false,
);

Map<String, dynamic> _$KehadiranModelToJson(KehadiranModel instance) =>
    <String, dynamic>{
      'data': instance.kehadiranResponse?.toJson(),
      'message': instance.message,
      'success': instance.success,
    };


