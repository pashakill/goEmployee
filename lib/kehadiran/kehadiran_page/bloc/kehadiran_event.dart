// bloc/login/login_event.dart
part of 'kehadiran_bloc.dart';

abstract class KehadiranEvent extends Equatable {
  const KehadiranEvent();

  @override
  List<Object> get props => [];
}

class CheckinButtonPressed extends KehadiranEvent {
  final String user_id;
  final String latitude;
  final String longitude;

  const CheckinButtonPressed({required this.user_id, required this.latitude, required this.longitude});

  @override
  List<Object> get props => [user_id, latitude, longitude];
}
