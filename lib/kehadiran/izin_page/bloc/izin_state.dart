part of 'izin_bloc.dart';

enum AddIzinStatus { initial, valid, invalid, loading, success, failure }

abstract class IzinState extends Equatable {
  const IzinState();

  @override
  List<Object> get props => [];
}

class IzinPageInitialState extends IzinState {}

class IzinPageLoadingState extends IzinState {}

class GetDataListIzinSuccessState extends IzinState {
  final DataCutiModel dataCutiModel;

  const GetDataListIzinSuccessState({required this.dataCutiModel});
  @override
  List<Object> get props => [dataCutiModel];
}

class AddIzinSuccessState extends IzinState {
  final IzinConverterModel izinConverterModel;

  const AddIzinSuccessState({required this.izinConverterModel});
  @override
  List<Object> get props => [izinConverterModel];
}

class EditIzinSuccessState extends IzinState {
  final IzinConverterModel izinConverterModel;

  const EditIzinSuccessState({required this.izinConverterModel});
  @override
  List<Object> get props => [izinConverterModel];
}

class DeleteIzinSuccessState extends IzinState {

  const DeleteIzinSuccessState();
  @override
  List<Object> get props => [];
}

class DeleteIzinFailedState extends IzinState {

  const DeleteIzinFailedState();
  @override
  List<Object> get props => [];
}

class IzinPageGlobalErorr extends IzinState {
  final NetworkError error;
  IzinPageGlobalErorr(this.error);
}

class IzinPageFailedState extends IzinState {
  final String error;
  const IzinPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
