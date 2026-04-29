import 'package:goemployee/kehadiran/slip_gaji/model/list_data_slip_gaji.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

import 'data_slip_gaji_models.dart';

part 'slip_gaji_response_model.g.dart';

@JsonSerializable()
class SlipGajiResponseModel {
  final bool success;
  final String message;

  @JsonKey(name: "data", defaultValue: [])
  final List<DataSlipGajiModels> data;

  SlipGajiResponseModel({
    required this.success,
    required this.data,
    required this.message,
  });

  factory SlipGajiResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SlipGajiResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SlipGajiResponseModelToJson(this);
}
