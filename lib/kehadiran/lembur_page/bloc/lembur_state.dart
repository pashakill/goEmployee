part of 'lembur_bloc.dart';

enum AddLemburStatus { initial, valid, invalid, loading, success, failure }

abstract class LemburState extends Equatable {
  const LemburState();

  @override
  List<Object> get props => [];
}

class LemburPageInitialState extends LemburState {}

class LemburPageLoadingState extends LemburState {}

class GetDataListLemburiSuccessState extends LemburState {
  final DataCutiModel dataCutiModel;

  const GetDataListLemburiSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class AddLemburSuccessState extends LemburState {
  final LemburModel cutiModel;

  const AddLemburSuccessState({required this.cutiModel});
  @override
  List<Object> get props => [cutiModel];
}

class EditLemburSuccessState extends LemburState {
  final LemburModel cutiModel;

  const EditLemburSuccessState({required this.cutiModel});
  @override
  List<Object> get props => [cutiModel];
}

class DeleteLemburSuccessState extends LemburState {

  const DeleteLemburSuccessState();
  @override
  List<Object> get props => [];
}

class LemburPageGlobalErorr extends LemburState {
  final NetworkError error;
  LemburPageGlobalErorr(this.error);
}


class DeleteLemburFailedState extends LemburState {

  const DeleteLemburFailedState();
  @override
  List<Object> get props => [];
}


class LemburPageFailedState extends LemburState {
  final String error;
  const LemburPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
