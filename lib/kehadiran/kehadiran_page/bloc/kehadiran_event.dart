// bloc/login/login_event.dart
part of 'kehadiran_bloc.dart';

abstract class KehadiranEvent extends Equatable {
  const KehadiranEvent();

  @override
  List<Object> get props => [];
}

class CheckoutButtonPressed extends KehadiranEvent {
  final String user_id;
  final String longitude;
  final String latitude;

  CheckoutButtonPressed({
    required this.user_id,
    required this.longitude,
    required this.latitude,
  });
}

class GetStatusAbsen extends KehadiranEvent {
  final String user_id;
  GetStatusAbsen({
    required this.user_id,
  });
}

class CheckinButtonPressed extends KehadiranEvent {
  final String user_id;
  final String latitude;
  final String longitude;

  const CheckinButtonPressed({required this.user_id, required this.latitude, required this.longitude});

  @override
  List<Object> get props => [user_id, latitude, longitude];
}
