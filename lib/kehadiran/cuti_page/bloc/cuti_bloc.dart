import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';

part 'cuti_event.dart';
part 'cuti_state.dart';

class CutiBloc extends Bloc<CutiEvent, CutiState> {
  final PengajuanApi pengajuanApi;

  CutiBloc({required this.pengajuanApi}) : super(CutiPageInitialState()) {
    on<CutiFetchedEvent>(_onFetchCuti);
    on<AddCutiEvent>(_onAddCuti);
  }

  void _onFetchCuti(CutiFetchedEvent event, Emitter<CutiState> emit) async {
    emit(CutiPageLoadingState());
    var data = await pengajuanApi.getList(userId: event.userId.toString(), kategori: PengajuanKategori.cuti);();
    if(data.success){
      emit(GetDataListCutiSuccessState(dataCutiModel: data));
    }else{
      emit(CutiPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onAddCuti(AddCutiEvent event, Emitter<CutiState> emit) async {
    emit(CutiPageLoadingState());
    var data = await pengajuanApi.addPengajuan(userId: event.userId.toString(), kategori: PengajuanKategori.cuti,
        cuti_kategori: event.jenis_cuti,
        tanggalMulai: event.tanggal_mulai, tanggalSelesai: event.tanggal_selesai, alasan: event.alasan, berkas: event.berkas);
    if(data.success){
      emit(AddCutiSuccessState(cutiModel: event.cutiModel));
    }else{
      emit(CutiPageFailedState(error: 'Menambahkan Cuti Gagal'));
    }
  }
}