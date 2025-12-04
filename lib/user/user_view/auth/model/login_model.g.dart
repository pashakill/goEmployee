// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginModel _$LoginModelFromJson(Map<String, dynamic> json) => LoginModel(
  json['data'] != null
      ? UserModels.fromJson(json['data'] as Map<String, dynamic>)
      : null,
  json['message'] as String? ?? '',
  json['success'] as bool? ?? false,
);

Map<String, dynamic> _$LoginModelToJson(LoginModel instance) =>
    <String, dynamic>{
      'data': instance.loginResponse?.toJson(),
      'message': instance.message,
      'success': instance.success,
    };


