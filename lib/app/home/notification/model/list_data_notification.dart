import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

part 'list_data_notification.g.dart';

@JsonSerializable()
class ListDataNotification {
  final List<DataNotificationModels> dataNotificationModels;

  ListDataNotification({required this.dataNotificationModels});

  factory ListDataNotification.fromJson(Map<String, dynamic> json) =>
      _$DataPengajuanFromJson(json);

  Map<String, dynamic> toJson() => _$DataPengajuanToJson(this);
}
