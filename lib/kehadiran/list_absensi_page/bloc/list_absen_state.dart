part of 'list_absen_bloc.dart';

enum ListAbsenStatus { initial, valid, invalid, loading, success, failure }

abstract class ListAbsenState extends Equatable {
  const ListAbsenState();

  @override
  List<Object> get props => [];
}

class ListAbsenPageInitialState extends ListAbsenState {}

class ListAbsenPageLoadingState extends ListAbsenState {}

class GetDataListAbsenSuccessState extends ListAbsenState {
  final List<AbsensiModel> data;

  const GetDataListAbsenSuccessState({required this.data});
  @override
  List<Object> get props => [data];
}


class ListAbsenPageGlobalErorr extends ListAbsenState {
  final NetworkError error;
  ListAbsenPageGlobalErorr(this.error);
}

class ListAbsenPageFailedState extends ListAbsenState {
  final String error;
  const ListAbsenPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
