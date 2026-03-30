import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'lembur_event.dart';
part 'lembur_state.dart';

class LemburBloc extends Bloc<LemburEvent, LemburState> {
  final PengajuanApi pengajuanApi;

  LemburBloc({required this.pengajuanApi}) : super(LemburPageInitialState()) {
    on<LemburFetchedEvent>(_onFetchLembur);
    on<AddLemburEvent>(_onAddLembur);
    on<EditLemburEvent>(_onEditLembur);
    on<DeleteLemburEvent>(_onDeleteLembur);
  }

  void _onFetchLembur(LemburFetchedEvent event, Emitter<LemburState> emit) async {
    emit(LemburPageLoadingState());
    var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.lembur);();
    if(data.success){
      emit(GetDataListLemburiSuccessState(dataCutiModel: data));
    }else{
      emit(LemburPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onAddLembur(AddLemburEvent event, Emitter<LemburState> emit) async {
    emit(LemburPageLoadingState());
    var data = await pengajuanApi.addPengajuan(
        userId: event.userId.toString(),
        kategori: PengajuanKategori.lembur,
        tanggalMulai: event.tanggal_mulai,
        lama: int.parse(event.durasi),
        alasan: event.alasan,
        tanggalSelesai: event.tanggal_selesai);
    if(data.success){
      emit(AddLemburSuccessState(cutiModel: event.lemburModel));
    }else{
      emit(LemburPageFailedState(error: 'Menambahkan Cuti Gagal'));
    }
  }

  void _onEditLembur(EditLemburEvent event, Emitter<LemburState> emit) async {
    emit(LemburPageLoadingState());
    var data = await pengajuanApi.editPengajuan(
        userId: event.userId.toString(),
        kategori: PengajuanKategori.lembur,
        tanggalMulai: event.tanggal_mulai,
        lama: int.parse(event.durasi),
        alasan: event.alasan,
        tanggalSelesai: event.tanggal_selesai, pengajuanId: event.pengajuanId);
    if(data.success){
      emit(EditLemburSuccessState(cutiModel: event.lemburModel));
    }else{
      emit(LemburPageFailedState(error: 'Menambahkan Cuti Gagal'));
    }
  }

  void _onDeleteLembur(DeleteLemburEvent event, Emitter<LemburState> emit) async {
    emit(LemburPageLoadingState());
    var data = await pengajuanApi.hapusPengajuan(
        userId: event.userId.toString(),
        pengajuanId: event.pengajuanId);
    if(data){
      emit(DeleteLemburSuccessState());
    }else{
      emit(DeleteLemburFailedState());
    }
  }
}