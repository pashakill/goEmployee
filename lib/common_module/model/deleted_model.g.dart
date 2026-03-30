// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeletedModel _$DeletedModelFromJson(Map<String, dynamic> json) =>
    DeletedModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );

Map<String, dynamic> _$DeletedModelToJson(DeletedModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
    };
