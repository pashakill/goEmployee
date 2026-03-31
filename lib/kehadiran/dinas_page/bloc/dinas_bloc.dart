import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'dinas_event.dart';
part 'dinas_state.dart';

class DinasBloc extends Bloc<DinasEvent, DinasState> {
  final PengajuanApi pengajuanApi;

  DinasBloc({required this.pengajuanApi}) : super(DinasPageInitialState()) {
    on<DinasFetchedEvent>(_onFetchDinas);
    on<AddDinasEvent>(_onAddDinas);
    on<UpdateDinasEvent>(_onEditDinas);
    on<DeleteDinasEvent>(_onDeleteDinas);
  }

  void _onFetchDinas(DinasFetchedEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    try{
      var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.dinas);();
      if(data.success){
        emit(GetDataListDinasSuccessState(dataCutiModel: data));
      }else{
        emit(DinasPageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    } catch(e){
      if (e is NetworkError) {
        emit(DinasPageGlobalErorr(e));
      } else {
        emit(DinasPageGlobalErorr(UnknownError()));
      }
    }

  }

  void _onAddDinas(AddDinasEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    try{
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
    } catch(e){
      if (e is NetworkError) {
        emit(DinasPageGlobalErorr(e));
      } else {
        emit(DinasPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onEditDinas(UpdateDinasEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    try{
      var data = await pengajuanApi.editPengajuan(
          userId: event.userId.toString(),
          kategori: PengajuanKategori.dinas,
          tanggalMulai: event.tanggal_mulai,
          tanggalSelesai: event.tanggal_selesai,
          alasan: event.alasan,
          alamat: event.alamat,
          latitude: event.latitude,
          longitude: event.longTitude, pengajuanId: event.id.toString()
      );
      if(data.success){
        emit(EditDinasSuccessState(dinasModel: event.dinasModel));
      }else{
        emit(DinasPageFailedState(error: 'Menambahkan Dinas Gagal'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(DinasPageGlobalErorr(e));
      } else {
        emit(DinasPageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onDeleteDinas(DeleteDinasEvent event, Emitter<DinasState> emit) async {
    emit(DinasPageLoadingState());
    try{
      var data = await pengajuanApi.hapusPengajuan(
          userId: event.userId.toString(),
          pengajuanId: event.id.toString()
      );
      if(data){
        emit(DeleteDinasSuccessState());
      }else{
        emit(DeleteDinasFailedState());
      }
    }catch(e){
      if (e is NetworkError) {
        emit(DinasPageGlobalErorr(e));
      } else {
        emit(DinasPageGlobalErorr(UnknownError()));
      }
    }
  }
}