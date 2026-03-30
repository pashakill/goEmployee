part of 'home_bloc.dart';

enum HomePageStatus { initial, valid, invalid, loading, success, failure }

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomePageInitialState extends HomeState {}

class HomePageLoadingState extends HomeState {}

class GetDataListNotificationSuccessState extends HomeState {
  final NotificationModel notificationModel;

  const GetDataListNotificationSuccessState({required this.notificationModel});
  @override
  List<Object> get props => [notificationModel];
}

class GlobalErorr extends HomeState {
  final NetworkError error;
  GlobalErorr(this.error);
}

class HomePageFailedState extends HomeState {
  final String error;
  const HomePageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
