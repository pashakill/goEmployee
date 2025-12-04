import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

import 'data_pengajuan.dart';

part 'add_data_cuti_model.g.dart';

@JsonSerializable()
class AddDataCutiModel {
  final bool success;
  final String message;

  AddDataCutiModel({
    required this.success,
    required this.message,
  });

  factory AddDataCutiModel.fromJson(Map<String, dynamic> json) =>
      _$AddDataCutiModelFromJson(json);

  Map<String, dynamic> toJson() => _$AddDataCutiModelToJson(this);
}
