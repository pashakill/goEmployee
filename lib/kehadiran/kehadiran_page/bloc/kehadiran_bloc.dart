import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'kehadiran_event.dart';
part 'kehadiran_state.dart';

class KehadiranBloc extends Bloc<KehadiranEvent, KehadiranState> {
  final KehadiranApi kehadiranApi;

  KehadiranBloc({required this.kehadiranApi}) : super(CheckinInitial()) {
    on<CheckinButtonPressed>(_onCheckInButtonPressed);
  }

  void _onCheckInButtonPressed(CheckinButtonPressed event, Emitter<KehadiranState> emit) async {
    emit(CheckinLoading());
    var data = await kehadiranApi.checkIn(user_id: event.user_id,
        latitude: event.latitude, longitude: event.longitude);
    if(data.success){
      emit(CheckinSuccess(kehadiranModel: data));
    }else{
      emit(CheckinFailure(error: 'Login Gagal'));
    }
  }
}
