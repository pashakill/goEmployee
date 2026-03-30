part of 'persetujuan_bloc.dart';

enum PersetujuanStatus { initial, valid, invalid, loading, success, failure }

abstract class PersetujuanState extends Equatable {
  const PersetujuanState();

  @override
  List<Object> get props => [];
}

class PersetujuanPageGlobalErorr extends DinasState {
  final NetworkError error;
  PersetujuanPageGlobalErorr(this.error);
}

class PersetujuanPageInitialState extends PersetujuanState {}

class PersetujuanPageLoadingState extends PersetujuanState {}

class GetDataListPersetujuanSuccessState extends PersetujuanState {
  final DataCutiModel dataCutiModel;

  const GetDataListPersetujuanSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class ApprovePersetujuanSuccessState extends PersetujuanState {
  const ApprovePersetujuanSuccessState();
  @override
  List<Object> get props => [];
}

class PersetujuanPageFailedState extends PersetujuanState {
  final String error;
  const PersetujuanPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
