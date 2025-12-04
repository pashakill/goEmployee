import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

import 'data_pengajuan.dart';

part 'data_cuti_model.g.dart';

@JsonSerializable()
class DataCutiModel {
  final bool success;
  final String message;

  @JsonKey(name: "data")
  final DataPengajuan? data;

  DataCutiModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory DataCutiModel.fromJson(Map<String, dynamic> json) =>
      _$DataCutiModelFromJson(json);

  Map<String, dynamic> toJson() => _$DataCutiModelToJson(this);
}
