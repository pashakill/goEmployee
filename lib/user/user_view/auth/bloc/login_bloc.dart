// bloc/login/login_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/goemployee.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final AuthApi authApi;

  LoginBloc({required this.authApi}) : super(LoginInitial()) {
    on<LoginButtonPressed>(_onLoginButtonPressed);
  }

  void _onLoginButtonPressed(LoginButtonPressed event, Emitter<LoginState> emit) async {
    emit(LoginLoading());
    var data = await authApi.login(username: event.username,
        password: event.password);

    print('data login ${data.toString()}');
    if(data.success){
      emit(LoginSuccess(loginResponse: data.loginResponse!));
    }else{
      emit(LoginFailure(error: 'Login Gagal'));
    }
  }
}
