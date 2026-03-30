// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_data_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListDataNotification _$DataPengajuanFromJson(Map<String, dynamic> json) =>
    ListDataNotification(
      dataNotificationModels: (json['notifications'] as List<dynamic>)
          .map((e) => DataNotificationModels.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataPengajuanToJson(ListDataNotification instance) =>
    <String, dynamic>{
      'notifications': instance.dataNotificationModels,
    };
