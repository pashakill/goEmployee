// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$DataNotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      data: json['data'] == null
          ? null
          : ListDataNotification.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$DataNotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'success': instance.success,
      'message': instance.message,
      'notifications': instance.data?.toJson(),
    };
