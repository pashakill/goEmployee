// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DataNotificationModels _$DataNotificationModelsFromJson(Map<String, dynamic> json) => DataNotificationModels(
  json['id'] as int,
  json['pengajuan_id'] as int,
  json['actor_role'] as String,
  json['action'] as String,
  json['message'] as String,
  json['created_at'] as String,
);

Map<String, dynamic> _$DataNotificationToJson(DataNotificationModels instance) => <String, dynamic>{
  'id': instance.id,
  'pengajuan_id': instance.pengajuanId,
  'actor_role': instance.actorRole,
  'action': instance.action,
  'message': instance.message,
  'created_at': instance.createdAt,
};
