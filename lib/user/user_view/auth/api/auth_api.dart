import 'package:goemployee/goemployee.dart';
import 'package:goemployee/user/user_view/auth/model/login_model.dart';

class AuthApi {
  final NetworkHelper network;

  AuthApi({required this.network});

  Future<LoginModel> login({required String username, required String password}) async {
    final response = await network.post("/login", {
      "username": username,
      "password": password,
    });
    return LoginModel.fromJson(response);
  }
}
