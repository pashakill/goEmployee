part of 'slip_gaji_bloc.dart';

enum UploadSlipGajiStatus { initial, valid, invalid, loading, success, failure }

abstract class SlipGajiState extends Equatable {
  const SlipGajiState();

  @override
  List<Object> get props => [];
}

class SlipGajiPageInitialState extends SlipGajiState {}

class SlipGajiPageLoadingState extends SlipGajiState {}

class GetDataListSlipGajiSuccessState extends SlipGajiState {
  final SlipGajiResponseModel slipGajiResponseModel;

  const GetDataListSlipGajiSuccessState({required this.slipGajiResponseModel});
  @override
  List<Object> get props => [slipGajiResponseModel];
}

class UploadSlipGajiSuccessState extends SlipGajiState {
  final bool success;

  const UploadSlipGajiSuccessState({required this.success});
  @override
  List<Object> get props => [success];
}

class FetchUserSuccessState extends SlipGajiState {
  final List<UserModel> userModel;

  const FetchUserSuccessState({required this.userModel});
  @override
  List<Object> get props => [userModel];
}

class SlipGajiPageGlobalErorr extends SlipGajiState {
  final NetworkError error;
  SlipGajiPageGlobalErorr(this.error);
}


class SlipGajiPageFailedState extends SlipGajiState {
  final String error;
  const SlipGajiPageFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
