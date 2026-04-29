part of 'slip_gaji_bloc.dart';

abstract class SlipGajiEvent extends Equatable {
  const SlipGajiEvent();

  @override
  List<Object> get props => [];
}

class SlipGajiFetchedEvent extends SlipGajiEvent {
  final int userId;
  const SlipGajiFetchedEvent({required this.userId});
}

class FetchUserEvent extends SlipGajiEvent {
  const FetchUserEvent();
}

class UploadSlipGajiEvent extends SlipGajiEvent {
  final int userId;
  final String bulan;
  final String tahun;
  final String fileBase64;

  const UploadSlipGajiEvent({required this.userId, required this.bulan, required this.tahun, required this.fileBase64});
}

