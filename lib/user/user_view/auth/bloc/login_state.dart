// bloc/login/login_state.dart
part of 'login_bloc.dart';

enum LoginStatus { initial, valid, invalid, loading, success, failure }

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final UserModels loginResponse;
  const LoginSuccess({required this.loginResponse});
  @override
  List<Object> get props => [loginResponse];
}

class LoginFailure extends LoginState {
  final String error;
  const LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}
