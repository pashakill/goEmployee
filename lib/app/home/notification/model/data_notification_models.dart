import 'package:goemployee/app/home/home.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_notification_models.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class DataNotificationModels {
  final int id;
  final int pengajuanId;
  final String actorRole;
  final String action;
  final String message;
  final String createdAt;

  DataNotificationModels(
      this.id,
      this.pengajuanId,
      this.actorRole,
      this.action,
      this.message,
      this.createdAt,
      );

  factory DataNotificationModels.fromJson(Map<String, dynamic> json) =>
      _$DataNotificationModelsFromJson(json);

  Map<String, dynamic> toJson() => _$DataNotificationToJson(this);
}
