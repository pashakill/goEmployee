import 'package:goemployee/kehadiran/slip_gaji/model/data_slip_gaji_models.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:goemployee/goemployee.dart';

part 'list_data_slip_gaji.g.dart';

@JsonSerializable()
class ListDataSlipGaji {
  final List<DataSlipGajiModels> dataSlipGajiModels;

  ListDataSlipGaji({required this.dataSlipGajiModels});

  factory ListDataSlipGaji.fromJson(Map<String, dynamic> json) =>
      _$ListDataSlipGajiFromJson(json);

  Map<String, dynamic> toJson() => _$ListDataSlipGajiToJson(this);
}
