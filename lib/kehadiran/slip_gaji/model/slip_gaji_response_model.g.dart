// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'slip_gaji_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SlipGajiResponseModel _$SlipGajiResponseModelFromJson(Map<String, dynamic> json) =>
    SlipGajiResponseModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: (json['data'] as List<dynamic>?)
          ?.map((e) =>
          DataSlipGajiModels.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );

Map<String, dynamic> _$SlipGajiResponseModelToJson(
    SlipGajiResponseModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'data': instance.data,
    };