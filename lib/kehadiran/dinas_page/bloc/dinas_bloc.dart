import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'dinas_event.dart';
part 'dinas_state.dart';

class DinasBloc extends Bloc<LemburEvent, DinasState> {
  final PengajuanApi pengajuanApi;

  DinasBloc({required this.pengajuanApi}) : super(DinasPageInitialState()) {
    on<DinasFetchedEvent>(_onFetchDinas);
    on<AddDinasEvent>(_onAddDinas);
  }

  void _onFetchDinas(DinasFetchedEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.dinas);();
    if(data.success){
      emit(GetDataListDinasSuccessState(dataCutiModel: data));
    }else{
      emit(DinasPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onAddDinas(AddDinasEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    var data = await pengajuanApi.addPengajuan(
        userId: event.userId.toString(),
        kategori: PengajuanKategori.dinas,
        tanggalMulai: event.tanggal_mulai,
        tanggalSelesai: event.tanggal_selesai,
        alasan: event.alasan,
        alamat: event.alamat,
        latitude: event.latitude,
        longitude: event.longTitude
    );
    if(data.success){
      emit(AddDinasSuccessState(dinasModel: event.dinasModel));
    }else{
      emit(DinasPageFailedState(error: 'Menambahkan Dinas Gagal'));
    }
  }
}