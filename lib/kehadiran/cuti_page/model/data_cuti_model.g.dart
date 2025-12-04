// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_cuti_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataCutiModel _$DataCutiModelFromJson(Map<String, dynamic> json) =>
    DataCutiModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : DataPengajuan.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataCutiModelToJson(DataCutiModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data?.toJson(),
    };
