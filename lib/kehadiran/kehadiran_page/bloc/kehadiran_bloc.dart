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
    on<CheckoutButtonPressed>(_onCheckout);
    on<GetStatusAbsen>(_getStatusAbsen);
    on<GetActiveLocation>(_getActiveLocation);
  }

  void _getStatusAbsen(GetStatusAbsen event, Emitter<KehadiranState> emit) async {
    emit(CheckinLoading());
    try{
      var data = await kehadiranApi.getStatusAbsen(userId: event.user_id);
      if(data.success){
        emit(GetStatusAbsenSuccess(statusKehadiranModel: data.data));
      }else{
        emit(CheckinFailure(error: 'Gagal ambil data'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(KehadiranPageGlobalErorr(e));
      } else {
        emit(KehadiranPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _getActiveLocation(GetActiveLocation event, Emitter<KehadiranState> emit) async {
    emit(CheckinLoading());
    try{
      var data = await kehadiranApi.getActiveLocation(userId: event.user_id);
      if(data.success){
        print('success');
        emit(GetActiveLocationSuccess(activeLocationResponseModel: data));
      }else{
        emit(CheckinFailure(error: 'Gagal ambil data'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(KehadiranPageGlobalErorr(e));
      } else {
        emit(KehadiranPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onCheckInButtonPressed(CheckinButtonPressed event, Emitter<KehadiranState> emit) async {
    emit(CheckinLoading());
    try{
      var data = await kehadiranApi.checkIn(user_id: event.user_id,
          latitude: event.latitude, longitude: event.longitude);
      if(data.success){
        emit(CheckinSuccess(kehadiranModel: data));
      }else{
        emit(CheckinFailure(error: 'Checkin Gagal'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(KehadiranPageGlobalErorr(e));
      } else {
        emit(KehadiranPageGlobalErorr(UnknownError()));
      }
    }
  }

  Future<void> _onCheckout(
      CheckoutButtonPressed event,
      Emitter<KehadiranState> emit,
      ) async {
    emit(CheckinLoading());

    try {
      final response = await kehadiranApi.checkout(
        userId: event.user_id,
        longitude: event.longitude,
        latitude: event.latitude,
      );

      if (response.success) {
        emit(CheckoutSuccess(kehadiranModel: response));
      } else {
        emit(CheckoutFailure("Checkout gagal"));
      }
    } catch (e) {
      if (e is NetworkError) {
        emit(KehadiranPageGlobalErorr(e));
      } else {
        emit(KehadiranPageGlobalErorr(UnknownError()));
      }
    }
  }
}
