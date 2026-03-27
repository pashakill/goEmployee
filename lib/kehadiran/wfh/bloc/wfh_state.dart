part of 'wfh_bloc.dart';

enum AddWfhStatus { initial, valid, invalid, loading, success, failure }

abstract class WfhState extends Equatable {
  const WfhState();

  @override
  List<Object> get props => [];
}

class WfhPageInitialState extends WfhState {}

class WfhPageLoadingState extends WfhState {}

class GetDataListWfhSuccessState extends WfhState {
  final DataCutiModel dataCutiModel;

  const GetDataListWfhSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class AddWfhSuccessState extends WfhState {
  final WfhModel wfhModel;

  const AddWfhSuccessState({required this.wfhModel});
  @override
  List<Object> get props => [wfhModel];
}

class WfhPageFailedState extends WfhState {
  final String error;
  const WfhPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
