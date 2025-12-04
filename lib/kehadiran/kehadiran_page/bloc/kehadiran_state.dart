part of 'kehadiran_bloc.dart';


enum LoginStatus { initial, valid, invalid, loading, success, failure }

abstract class KehadiranState extends Equatable {
  const KehadiranState();

  @override
  List<Object> get props => [];
}

class CheckinInitial extends KehadiranState {}

class CheckinLoading extends KehadiranState {}

class CheckinSuccess extends KehadiranState {
  final KehadiranModel kehadiranModel;
  const CheckinSuccess({required this.kehadiranModel});
  @override
  List<Object> get props => [kehadiranModel];
}

class CheckinFailure extends KehadiranState {
  final String error;
  const CheckinFailure({required this.error});

  @override
  List<Object> get props => [error];
}
