import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

part 'notification_model.g.dart';

@JsonSerializable()
class NotificationModel {
  final bool success;
  final String message;

  @JsonKey(name: "data")
  final ListDataNotification? data;

  NotificationModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$DataNotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataNotificationModelToJson(this);
}
