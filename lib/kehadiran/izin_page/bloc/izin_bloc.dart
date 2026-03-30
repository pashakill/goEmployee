import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'izin_event.dart';
part 'izin_state.dart';

class IzinBloc extends Bloc<IzinEvent, IzinState> {
  final PengajuanApi pengajuanApi;

  IzinBloc({required this.pengajuanApi}) : super(IzinPageInitialState()) {
    on<IzinFetchedEvent>(_onFetchIzin);
    on<AddIzinEvent>(_onAddIzin);
    on<EditIzinEvent>(_onEditIzin);
    on<DeleteIzinEvent>(_onDeleteIzin);
  }

  void _onFetchIzin(IzinFetchedEvent event, Emitter<IzinState> emit) async {
    emit(IzinPageLoadingState());
    var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.izin);();
    if(data.success){
      emit(GetDataListIzinSuccessState(dataCutiModel: data));
    }else{
      emit(IzinPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onAddIzin(AddIzinEvent event, Emitter<IzinState> emit) async {
    emit(IzinPageLoadingState());
    var data = await pengajuanApi.addPengajuan(
        userId: event.userId.toString(),
        izinKategori: event.izinTipe,
        kategori: PengajuanKategori.izin,
        tanggalMulai: event.tanggal,
        alasan: event.alasan,
        jamIzin: event.jam,
        tanggalSelesai: event.tanggal
    );
    if(data.success){
      emit(AddIzinSuccessState(izinConverterModel: event.izinConverterModel));
    }else{
      emit(IzinPageFailedState(error: 'Menambahkan Dinas Gagal'));
    }
  }

  void _onEditIzin(EditIzinEvent event, Emitter<IzinState> emit) async {
    emit(IzinPageLoadingState());
    var data = await pengajuanApi.editPengajuan(
        userId: event.userId.toString(),
        izinKategori: event.izinTipe,
        kategori: PengajuanKategori.izin,
        tanggalMulai: event.tanggal,
        alasan: event.alasan,
        jamIzin: event.jam,
        tanggalSelesai: event.tanggal,
        pengajuanId: event.id
    );
    if(data.success){
      emit(EditIzinSuccessState(izinConverterModel: event.izinConverterModel));
    }else{
      emit(IzinPageFailedState(error: 'Menambahkan Dinas Gagal'));
    }
  }

  void _onDeleteIzin(DeleteIzinEvent event, Emitter<IzinState> emit) async {
    emit(IzinPageLoadingState());
    var data = await pengajuanApi.hapusPengajuan(
        userId: event.userId.toString(),
        pengajuanId: event.id
    );
    if(data){
      emit(DeleteIzinSuccessState());
    }else{
      emit(DeleteIzinFailedState());
    }
  }
}