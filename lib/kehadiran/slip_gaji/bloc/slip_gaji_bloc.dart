import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/slip_gaji/slip_gaji.dart';

import '../model/slip_gaji_response_model.dart';

part 'slip_gaji_event.dart';
part 'slip_gaji_state.dart';

class SlipGajiBloc extends Bloc<SlipGajiEvent, SlipGajiState> {
  final SlipGajiApi slipGajiApi;

  SlipGajiBloc({required this.slipGajiApi}) : super(SlipGajiPageInitialState()) {
    on<SlipGajiFetchedEvent>(_onFetchSlipGaji);
    on<UploadSlipGajiEvent>(_onUploadSlipGaji);
    on<FetchUserEvent>(_onUFetchUser);
  }

  void _onFetchSlipGaji(SlipGajiFetchedEvent event, Emitter<SlipGajiState> emit) async {
    emit(SlipGajiPageLoadingState());
    try{
      var data = await slipGajiApi.getListSlipGaji(
        userId: event.userId.toString(),
      );
      print("RAW RESPONSE: ${data.toJson()}");
      print("SUCCESS VALUE: ${data.success}");
      if(data.success){
        print('SUKSES GET');
        emit(GetDataListSlipGajiSuccessState(slipGajiResponseModel: data));
      }else{
        emit(SlipGajiPageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(SlipGajiPageGlobalErorr(e));
      } else {
        emit(SlipGajiPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onUploadSlipGaji(UploadSlipGajiEvent event, Emitter<SlipGajiState> emit) async {
    emit(SlipGajiPageLoadingState());
    try{
      var data = await slipGajiApi.uploadSlipGaji(
        userId: event.userId.toString(), bulan: event.bulan, tahun: event.tahun, file: event.fileBase64,
      );
      if(data.success){
        emit(UploadSlipGajiSuccessState(success: data.success));
      }else{
        emit(SlipGajiPageFailedState(error: 'Upload Slip Gaji Gagal'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(SlipGajiPageGlobalErorr(e));
      } else {
        emit(SlipGajiPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onUFetchUser(FetchUserEvent event, Emitter<SlipGajiState> emit) async {
    emit(SlipGajiPageLoadingState());
    try{
      var data = await slipGajiApi.getListUser();
      if(!data.isEmpty){
        emit(FetchUserSuccessState(userModel: data));
      }else{
        emit(SlipGajiPageFailedState(error: 'Fetch User Gagal'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(SlipGajiPageGlobalErorr(e));
      } else {
        emit(SlipGajiPageGlobalErorr(UnknownError()));
      }
    }
  }
}