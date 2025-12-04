import 'package:goemployee/goemployee.dart';
import 'package:goemployee/user/user_view/auth/model/login_model.dart';

class KehadiranApi {
  final NetworkHelper network;

  KehadiranApi({required this.network});

  Future<KehadiranModel> checkIn({required String user_id, required String latitude, required String longitude}) async {
    final response = await network.post("/absen/checkin", {
      "user_id": user_id,
      "latitude": latitude,
      "longitude": longitude
    });
    return KehadiranModel.fromJson(response);
  }
}
