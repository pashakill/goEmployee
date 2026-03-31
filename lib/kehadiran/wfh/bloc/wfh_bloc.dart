import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'wfh_event.dart';
part 'wfh_state.dart';

class WfhBloc extends Bloc<WfhEvent, WfhState> {
  final PengajuanApi pengajuanApi;

  WfhBloc({required this.pengajuanApi}) : super(WfhPageInitialState()) {
    on<WfhFetchedEvent>(_onFetchWfh);
    on<AddWfhEvent>(_onAddWfh);
    on<EditWfhEvent>(_onEditWfh);
    on<DeleteWfhEvent>(_onDeleteWfh);
  }

  void _onFetchWfh(WfhFetchedEvent event, Emitter<WfhState> emit) async {
    emit(WfhPageLoadingState());
    try{
      var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.wfh);();
      if(data.success){
        emit(GetDataListWfhSuccessState(dataCutiModel: data));
      }else{
        emit(WfhPageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(WfhPageGlobalErorr(e));
      } else {
        emit(WfhPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onAddWfh(AddWfhEvent event, Emitter<WfhState> emit) async {
    emit(WfhPageLoadingState());
    try{
      var data = await pengajuanApi.addPengajuan(
        userId: event.userId.toString(),
        lama: int.parse(event.durasi),
        kategori: PengajuanKategori.wfh,
        tanggalMulai: event.waktuMulai,
        tanggalSelesai: event.waktuSelesai,
        alasan: event.alasan,
      );
      if(data.success){
        emit(AddWfhSuccessState(wfhModel: event.wfhModel));
      }else{
        emit(WfhPageFailedState(error: 'Menambahkan Wfh Gagal'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(WfhPageGlobalErorr(e));
      } else {
        emit(WfhPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onEditWfh(EditWfhEvent event, Emitter<WfhState> emit) async {
    emit(WfhPageLoadingState());
    try{
      var data = await pengajuanApi.editPengajuan(
        userId: event.userId.toString(),
        lama: int.parse(event.durasi),
        kategori: PengajuanKategori.wfh,
        tanggalMulai: event.waktuMulai,
        tanggalSelesai: event.waktuSelesai,
        alasan: event.alasan, pengajuanId: event.id,
      );
      if(data.success){
        emit(AddWfhSuccessState(wfhModel: event.wfhModel));
      }else{
        emit(WfhPageFailedState(error: 'Edit Wfh Gagal'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(WfhPageGlobalErorr(e));
      } else {
        emit(WfhPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onDeleteWfh(DeleteWfhEvent event, Emitter<WfhState> emit) async {
    emit(WfhPageLoadingState());
    try{
      var data = await pengajuanApi.hapusPengajuan(
        userId: event.userId.toString(),
        pengajuanId: event.id,
      );
      if(data){
        emit(DeleteWfhSuccessState());
      }else{
        emit(DeleteWfhFailedState());
      }
    }catch(e){
      if (e is NetworkError) {
        emit(WfhPageGlobalErorr(e));
      } else {
        emit(WfhPageGlobalErorr(UnknownError()));
      }
    }
  }
}