import 'package:json_annotation/json_annotation.dart';

part 'user_models.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class UserModels {
  final int id;
  final String nama;
  final String username;
  final String password;
  final String companyName;
  final String role;
  final String dateNow;
  final String? timeCheckin;
  final String? timeCheckout;
  final String? lateCheckin;
  final String? photo;
  final String? jadwalMulaiKerja;
  final String? jadwalSelesaiKerja;
  final String? latitude;
  final String? longitude;
  final String? radius;

  UserModels(
      this.id,
      this.nama,
      this.username,
      this.password,
      this.companyName,
      this.role,
      this.dateNow,
      this.timeCheckin,
      this.timeCheckout,
      this.lateCheckin,
      this.photo,
      this.jadwalMulaiKerja,
      this.jadwalSelesaiKerja,
      this.latitude,
      this.longitude,
      this.radius
      );

  factory UserModels.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);

}
