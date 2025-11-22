import 'package:goemployee/goemployee.dart';

class AuthApi {
  final NetworkHelper network;

  AuthApi({required this.network});

  Future<void> login({required String username, required String password}) async {
    final response = await network.post("/api/auth/login", {
      "username": username,
      "password_hash": password,
    });

    if (response["status"] != true) {
      throw Exception(response["message"] ?? "Login gagal");
    }
  }
}
