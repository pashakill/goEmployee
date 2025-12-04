import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

part 'kehadiran_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class KehadiranModel {
  final String message;
  final bool success;

  @JsonKey(name: 'data')
  final KehadiranResponseModel? kehadiranResponse; // nullable

  KehadiranModel(this.kehadiranResponse, this.message, this.success);

  factory KehadiranModel.fromJson(Map<String, dynamic> json) =>
      _$KehadiranModelFromJson(json);

  Map<String, dynamic> toJson() => _$KehadiranModelToJson(this);

  @override
  String toString() {
    return 'KehadiranResponse(success: $success, message: "$message", loginResponse: $kehadiranResponse)';
  }
}