part of 'wfh_bloc.dart';

abstract class WfhEvent extends Equatable {
  const WfhEvent();

  @override
  List<Object> get props => [];
}

class WfhFetchedEvent extends WfhEvent {
  final int userId;
  const WfhFetchedEvent({required this.userId});
}

class AddWfhEvent extends WfhEvent {
  final WfhModel wfhModel;
  final int userId;
  final String lamaWfh;
  final String alasanWfh;
  final String waktuMulai;
  final String waktuSelesai;
  final String tanggalPengajuan;
  final String alasan;
  final String durasi;

  const AddWfhEvent(this.wfhModel, {required this.userId, required this.lamaWfh, required this.alasan,
    required this.alasanWfh, required this.waktuMulai, required this.waktuSelesai, required this.durasi, required this.tanggalPengajuan});
}


class EditWfhEvent extends WfhEvent {
  final String id;
  final WfhModel wfhModel;
  final int userId;
  final String lamaWfh;
  final String alasanWfh;
  final String waktuMulai;
  final String waktuSelesai;
  final String tanggalPengajuan;
  final String alasan;
  final String durasi;

  const EditWfhEvent(this.wfhModel, {required this.id, required this.userId, required this.lamaWfh, required this.alasan,
    required this.alasanWfh, required this.waktuMulai, required this.waktuSelesai, required this.durasi, required this.tanggalPengajuan});
}

class DeleteWfhEvent extends WfhEvent {
  final String id;
  final int userId;

  const DeleteWfhEvent({required this.id, required this.userId});
}