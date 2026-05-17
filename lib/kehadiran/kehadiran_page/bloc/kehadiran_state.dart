part of 'kehadiran_bloc.dart';


enum LoginStatus { initial, valid, invalid, loading, success, failure }

abstract class KehadiranState extends Equatable {
  const KehadiranState();
  @override
  List<Object> get props => [];
}

class KehadiranPageGlobalErorr extends KehadiranState {
  final NetworkError error;
  KehadiranPageGlobalErorr(this.error);
}

class CheckinInitial extends KehadiranState {}
class CheckinLoading extends KehadiranState {}

class CheckinSuccess extends KehadiranState {
  final KehadiranModel kehadiranModel;
  const CheckinSuccess({required this.kehadiranModel});
  @override
  List<Object> get props => [kehadiranModel];
}

class GetStatusAbsenSuccess extends KehadiranState {
  final StatusKehadiranModel statusKehadiranModel;

  const GetStatusAbsenSuccess({required this.statusKehadiranModel});
  @override
  List<Object> get props => [statusKehadiranModel];
}


class GetActiveLocationSuccess extends KehadiranState {
  final ActiveLocationResponseModel activeLocationResponseModel;

  const GetActiveLocationSuccess({required this.activeLocationResponseModel});
  @override
  List<Object> get props => [activeLocationResponseModel];
}


class CheckoutSuccess extends KehadiranState {
  final KehadiranModel kehadiranModel;
  CheckoutSuccess({required this.kehadiranModel});
}

class CheckoutFailure extends KehadiranState {
  final String error;
  CheckoutFailure(this.error);
}

class CheckinFailure extends KehadiranState {
  final String error;
  const CheckinFailure({required this.error});

  @override
  List<Object> get props => [error];
}
