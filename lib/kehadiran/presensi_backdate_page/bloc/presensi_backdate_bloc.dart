import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'presensi_backdate_event.dart';
part 'presensi_backdate_state.dart';

class PresensiBackdateBloc extends Bloc<PresensiBackdateEvent, PresensiBackdateState> {
  final PengajuanApi pengajuanApi;

  PresensiBackdateBloc({required this.pengajuanApi}) : super(PresensiBackdatePageInitialState()) {
    on<PresensiBackdateFetchedEvent>(_onFetchPresensiBackdate);
    on<AddPresensiBackdateEvent>(_onAddPresensiBackdate);
    on<EditPresensiBackdateEvent>(_onEditPresensiBackdate);
    on<DeletePresensiBackdateEvent>(_onDeletePresensiBackdate);
  }

  void _onFetchPresensiBackdate(PresensiBackdateFetchedEvent event, Emitter<PresensiBackdateState> emit) async {
    emit(PresensiBackdatePageLoadingState());
    try{
      var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.presensiBackdate);();
      if(data.success){
        emit(GetDataListPresensiBackdateSuccessState(dataCutiModel: data));
      }else{
        emit(PresensiBackdatePageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    } catch(e){
      if (e is NetworkError) {
        emit(PresensiBackdatePageGlobalErorr(e));
      } else {
        emit(PresensiBackdatePageGlobalErorr(UnknownError()));
      }
    }

  }

  void _onAddPresensiBackdate(AddPresensiBackdateEvent event, Emitter<PresensiBackdateState> emit) async {
    emit(PresensiBackdatePageLoadingState());
    try{
      var data = await pengajuanApi.addPengajuan(
          berkas: event.berkas,
          cuti_kategori: event.terlambat,
          userId: event.userId.toString(),
          kategori: PengajuanKategori.presensiBackdate,
          tanggalMulai: event.tanggal_mulai,
          tanggalSelesai: event.tanggal_selesai,
          alasan: event.alasan,
          jamMulai: event.jam_mulai,
          jamSelesai: event.jam_selesai,
      );
      if(data.success){
        emit(AddPresensiBackdateSuccessState(presensiBackdateModel: event.model));
      }else{
        emit(PresensiBackdatePageFailedState(error: 'Menambahkan Presensi Backdate Gagal'));
      }
    } catch(e){
      if (e is NetworkError) {
        emit(PresensiBackdatePageGlobalErorr(e));
      } else {
        emit(PresensiBackdatePageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onEditPresensiBackdate(EditPresensiBackdateEvent event, Emitter<PresensiBackdateState> emit) async {
    emit(PresensiBackdatePageLoadingState());
    try{
      var data = await pengajuanApi.addPengajuan(
        userId: event.userId.toString(),
        kategori: PengajuanKategori.presensiBackdate,
        tanggalMulai: event.tanggal_mulai,
        tanggalSelesai: event.tanggal_selesai,
        alasan: event.alasan,
        jamMulai: event.jam_mulai,
        jamSelesai: event.jam_selesai,
      );
      if(data.success){
        emit(EditPresensiBackdateSuccessState(presensiBackdateModel: event.presensiBackdateModel));
      }else{
        emit(PresensiBackdatePageFailedState(error: 'Menambahkan Presensi Backdate Gagal'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(PresensiBackdatePageGlobalErorr(e));
      } else {
        emit(PresensiBackdatePageGlobalErorr(UnknownError()));
      }
    }
  }

  void _onDeletePresensiBackdate(DeletePresensiBackdateEvent event, Emitter<PresensiBackdateState> emit) async {
    emit(PresensiBackdatePageLoadingState());
    try{
      var data = await pengajuanApi.hapusPengajuan(
          userId: event.userId.toString(),
          pengajuanId: event.pengajuanId.toString()
      );
      if(data){
        emit(DeletePresensiBackdateSuccessState());
      }else{
        emit(DeletePresensiBackdateFailedState());
      }
    }catch(e){
      if (e is NetworkError) {
        emit(PresensiBackdatePageGlobalErorr(e));
      } else {
        emit(PresensiBackdatePageGlobalErorr(UnknownError()));
      }
    }
  }
}