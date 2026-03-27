part of 'dinas_bloc.dart';

enum AddDinasStatus { initial, valid, invalid, loading, success, failure }

abstract class DinasState extends Equatable {
  const DinasState();

  @override
  List<Object> get props => [];
}

class DinasPageInitialState extends DinasState {}

class DinasPageLoadingState extends DinasState {}

class GetDataListDinasSuccessState extends DinasState {
  final DataCutiModel dataCutiModel;

  const GetDataListDinasSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class AddDinasSuccessState extends DinasState {
  final DinasModel dinasModel;

  const AddDinasSuccessState({required this.dinasModel});
  @override
  List<Object> get props => [dinasModel];
}

class DinasPageFailedState extends DinasState {
  final String error;
  const DinasPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
