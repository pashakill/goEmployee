part of 'cuti_bloc.dart';

enum AddStatus { initial, valid, invalid, loading, success, failure }

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


class UpdateCutiSuccessState extends CutiState {
  final CutiModel cutiModel;

  const UpdateCutiSuccessState({required this.cutiModel});
  @override
  List<Object> get props => [cutiModel];
}

class CutiPageGlobalErorr extends CutiState {
  final NetworkError error;
  CutiPageGlobalErorr(this.error);
}

class DeleteCutiSuccessState extends CutiState {
  final String id;
  const DeleteCutiSuccessState({required this.id});

  @override
  List<Object> get props => [id];
}

class DeleteCutiFailedState extends CutiState {
  final String id;
  const DeleteCutiFailedState({required this.id});

  @override
  List<Object> get props => [id];
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
