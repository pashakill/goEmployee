import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

part 'deleted_model.g.dart';

@JsonSerializable()
class DeletedModel {
  final bool success;
  final String message;

  DeletedModel({
    required this.success,
    required this.message,
  });

  factory DeletedModel.fromJson(Map<String, dynamic> json) =>
      _$DeletedModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeletedModelToJson(this);
}
