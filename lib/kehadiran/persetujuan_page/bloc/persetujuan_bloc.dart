import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/persetujuan_page/api/api.dart';

part 'persetujuan_event.dart';
part 'persetujuan_state.dart';

class PersetujuanBloc extends Bloc<PersetujuanEvent, PersetujuanState> {
  final PersetujuanApi persetujuanApi;

  PersetujuanBloc({required this.persetujuanApi}) : super(PersetujuanPageInitialState()) {
    on<PersetujuanFetchedEvent>(_onFetchPersetujuan);
    on<ApprovePersetujuanEvent>(_onApprovePersetujuan);
  }

  void _onFetchPersetujuan(PersetujuanFetchedEvent event, Emitter<PersetujuanState> emit) async {
    emit(PersetujuanPageLoadingState());
    var data = await persetujuanApi.getDataListPengajuan(userId: event.userId.toString(), userRole: event.role, divisiId: event.divisiId);();
    if(data.success){
      emit(GetDataListPersetujuanSuccessState(dataCutiModel: data));
    }else{
      emit(PersetujuanPageFailedState(error: 'Gagal Mendapatkan List Data'));
    }
  }

  void _onApprovePersetujuan(ApprovePersetujuanEvent event, Emitter<PersetujuanState> emit) async {
    emit(PersetujuanPageLoadingState());
    var data = await persetujuanApi.approveDataPengajuan(pengajuan_id: event.userId, role: event.role, action: event.actions, divisi_id: event.divisiId);
    if(data.success){
      emit(ApprovePersetujuanSuccessState());
    }else{
      emit(PersetujuanPageFailedState(error: 'Approve Gagal'));
    }
  }
}