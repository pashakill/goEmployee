


import 'package:goemployee/user/user_view/auth/model/user_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'kehadiran_response.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class KehadiranResponseModel {

  final String tanggal;
  final String jamMasuk;
  final String terlambat;
  final String latitude;
  final String longitude;

  KehadiranResponseModel(this.tanggal, this.jamMasuk, this.terlambat, this.latitude, this.longitude);

  factory KehadiranResponseModel.fromJson(Map<String, dynamic> json) =>
      _$KehadiranResponseFromJson(json);

  Map<String, dynamic> toJson() => _$KehadiranResponseToJson(this);

  @override
  String toString() {
    return 'LoginModel(tanggal: $tanggal, jamMasuk: "$jamMasuk", terlambat: $terlambat, '
        'latitude: $latitude, longitude: $longitude)';
  }
}