import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/common_module/api/pengajuan_api.dart';
import 'package:goemployee/goemployee.dart';
import 'package:goemployee/kehadiran/kehadiran_page/api/api.dart';

part 'list_absen_event.dart';
part 'list_absen_state.dart';

class ListAbsenBloc extends Bloc<ListAbsenEvent, ListAbsenState> {
  final ListAbsenApi listAbsenApi;

  ListAbsenBloc({required this.listAbsenApi}) : super(ListAbsenPageInitialState()) {
    on<ListAbsenFetchedEvent>(_onFetchWfh);}

  void _onFetchWfh(ListAbsenFetchedEvent event, Emitter<ListAbsenState> emit) async {
    emit(ListAbsenPageLoadingState());
    try{
      var data = await listAbsenApi.getListAbsen(userId: event.userId.toString(), from: event.from, to: event.to, status: event.status);
      if(data.success){
        emit(GetDataListAbsenSuccessState(data: data.data));
      }else{
        emit(ListAbsenPageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    }catch(e){
      if (e is NetworkError) {
        emit(ListAbsenPageGlobalErorr(e));
      } else {
        emit(ListAbsenPageGlobalErorr(UnknownError()));
      }
    }
  }
}