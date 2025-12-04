import 'package:json_annotation/json_annotation.dart';

import '../repo/pengajuan_response.dart';

part 'data_pengajuan.g.dart';

@JsonSerializable()
class DataPengajuan {
  final List<PengajuanData> pengajuan;

  DataPengajuan({required this.pengajuan});

  factory DataPengajuan.fromJson(Map<String, dynamic> json) =>
      _$DataPengajuanFromJson(json);

  Map<String, dynamic> toJson() => _$DataPengajuanToJson(this);
}
