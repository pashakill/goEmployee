part of 'presensi_backdate_bloc.dart';

enum PresensiBackdateStatus { initial, valid, invalid, loading, success, failure }

abstract class PresensiBackdateState extends Equatable {
  const PresensiBackdateState();

  @override
  List<Object> get props => [];
}

class PresensiBackdatePageInitialState extends PresensiBackdateState {}

class PresensiBackdatePageLoadingState extends PresensiBackdateState {}

class GetDataListPresensiBackdateSuccessState extends PresensiBackdateState {
  final DataCutiModel dataCutiModel;

  const GetDataListPresensiBackdateSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class EditPresensiBackdateSuccessState extends PresensiBackdateState {
  final PresensiBackdateModel presensiBackdateModel;

  const EditPresensiBackdateSuccessState({required this.presensiBackdateModel});
  @override
  List<Object> get props => [presensiBackdateModel];
}


class DeletePresensiBackdateSuccessState extends PresensiBackdateState {

  const DeletePresensiBackdateSuccessState();
  @override
  List<Object> get props => [];
}

class PresensiBackdatePageGlobalErorr extends PresensiBackdateState {
  final NetworkError error;
  PresensiBackdatePageGlobalErorr(this.error);
}

class DeletePresensiBackdateFailedState extends PresensiBackdateState {

  const DeletePresensiBackdateFailedState();
  @override
  List<Object> get props => [];
}

class AddPresensiBackdateSuccessState extends PresensiBackdateState {
  final PresensiBackdateModel presensiBackdateModel;

  const AddPresensiBackdateSuccessState({required this.presensiBackdateModel});
  @override
  List<Object> get props => [presensiBackdateModel];
}

class PresensiBackdatePageFailedState extends PresensiBackdateState {
  final String error;
  const PresensiBackdatePageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
