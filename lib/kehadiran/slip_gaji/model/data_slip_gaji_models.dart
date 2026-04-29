import 'package:goemployee/app/home/home.dart';
import 'package:json_annotation/json_annotation.dart';

part 'data_slip_gaji_models.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class DataSlipGajiModels {
  final String id;
  final String bulan;
  final String tahun;
  @JsonKey(name: "file")
  final String file;

  DataSlipGajiModels(
      this.id,
      this.bulan,
      this.tahun,
      this.file,
      );

  factory DataSlipGajiModels.fromJson(Map<String, dynamic> json) =>
      _$DataSlipGajiModelsFromJson(json);

  Map<String, dynamic> toJson() => _$DataSlipGajiToJson(this);
}
