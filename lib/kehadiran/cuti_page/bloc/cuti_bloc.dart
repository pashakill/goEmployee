import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'cuti_event.dart';
part 'cuti_state.dart';

class CutiBloc extends Bloc<CutiEvent, CutiState> {
  final CutiApi cutiApi;

  CutiBloc({required this.cutiApi}) : super(CutiPageInitialState()) {
    on<CutiFetchedEvent>(_onFetchCuti);
    on<AddCutiEvent>(_onAddCuti);
  }

  void _onFetchCuti(CutiFetchedEvent event, Emitter<CutiState> emit) async {
    emit(CutiPageLoadingState());
    var data = await cutiApi.getListCuti(event.userId.toString());
    if(data.success){
      emit(GetDataListCutiSuccessState(dataCutiModel: data));
    }else{
      emit(CutiPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onAddCuti(AddCutiEvent event, Emitter<CutiState> emit) async {
    emit(CutiPageLoadingState());
    var data = await cutiApi.addCuti(event.userId.toString(),
        event.kategori, event.tanggal_mulai, event.tanggal_selesai, event.alasan, event.berkas, event.cutiModel);
    if(data.success){
      emit(AddCutiSuccessState(cutiModel: event.cutiModel));
    }else{
      emit(CutiPageFailedState(error: 'Menambahkan Cuti Gagal'));
    }
  }
}
