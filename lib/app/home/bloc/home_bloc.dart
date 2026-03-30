import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:goemployee/app/home/api/home_api.dart';
import 'package:goemployee/goemployee.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeApi homeApi;

  HomeBloc({required this.homeApi}) : super(HomePageInitialState()) {
    on<NotificationFetchedEvent>(_onFetchNotification);
  }

  void _onFetchNotification(NotificationFetchedEvent event, Emitter<HomeState> emit) async {
    emit(HomePageLoadingState());
    try{
      var data = await homeApi.getListNotification(userId: event.userId.toString());
      print(data.toString());

      if(data.success){
        emit(GetDataListNotificationSuccessState(notificationModel: data));
      }else{
        emit(HomePageFailedState(error: 'Gagal Mendapatkan List Data'));
      }
    }catch (e){
      if (e is NetworkError) {
        emit(GlobalErorr(e));
      } else {
        emit(GlobalErorr(UnknownError()));
      }
    }
  }
}