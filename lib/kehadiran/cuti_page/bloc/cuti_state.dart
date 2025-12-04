part of 'cuti_bloc.dart';

enum LoginStatus { initial, valid, invalid, loading, success, failure }

abstract class CutiState extends Equatable {
  const CutiState();

  @override
  List<Object> get props => [];
}

class CutiPageInitialState extends CutiState {}

class CutiPageLoadingState extends CutiState {}

class GetDataListCutiSuccessState extends CutiState {
  final DataCutiModel dataCutiModel;

  const GetDataListCutiSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class AddCutiSuccessState extends CutiState {
  final CutiModel cutiModel;

  const AddCutiSuccessState({required this.cutiModel});
  @override
  List<Object> get props => [cutiModel];
}

class CutiPageFailedState extends CutiState {
  final String error;
  const CutiPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
