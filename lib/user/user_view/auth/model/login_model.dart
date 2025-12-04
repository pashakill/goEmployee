import 'package:goemployee/user/user_view/auth/model/user_models.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable(createFactory: true, createToJson: true)
class LoginModel {
  final String message;
  final bool success;

  @JsonKey(name: 'data')
  final UserModels? loginResponse; // nullable

  LoginModel(this.loginResponse, this.message, this.success);

  factory LoginModel.fromJson(Map<String, dynamic> json) =>
      _$LoginModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);

  @override
  String toString() {
    return 'LoginModel(success: $success, message: "$message", loginResponse: $loginResponse)';
  }
}