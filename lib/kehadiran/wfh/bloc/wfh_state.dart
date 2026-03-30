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

class EditWfhSuccessState extends WfhState {
  final WfhModel wfhModel;

  const EditWfhSuccessState({required this.wfhModel});
  @override
  List<Object> get props => [wfhModel];
}

class DeleteWfhSuccessState extends WfhState {
  const DeleteWfhSuccessState();
  @override
  List<Object> get props => [];
}

class WfhPageGlobalErorr extends DinasState {
  final NetworkError error;
  WfhPageGlobalErorr(this.error);
}

class DeleteWfhFailedState extends WfhState {
  const DeleteWfhFailedState();
  @override
  List<Object> get props => [];
}

class WfhPageFailedState extends WfhState {
  final String error;
  const WfhPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
