part of 'dinas_bloc.dart';

abstract class DinasEvent extends Equatable {
  const DinasEvent();

  @override
  List<Object> get props => [];
}

class DinasFetchedEvent extends DinasEvent {
  final int userId;
  const DinasFetchedEvent({required this.userId});
}

class AddDinasEvent extends DinasEvent {
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String alamat;
  final String latitude;
  final String longTitude;
  final String alasan;
  final DinasModel dinasModel;

  const AddDinasEvent(this.dinasModel, {required this.userId, required this.kategori,
    required this.tanggal_mulai, required this.tanggal_selesai, required this.alamat, required this.latitude,
    required this.longTitude,
    required this.alasan});
}

class UpdateDinasEvent extends DinasEvent {
  final int id;
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String alamat;
  final String latitude;
  final String longTitude;
  final String alasan;
  final DinasModel dinasModel;

  const UpdateDinasEvent(this.dinasModel, {required this.id, required this.userId, required this.kategori,
    required this.tanggal_mulai, required this.tanggal_selesai, required this.alamat, required this.latitude,
    required this.longTitude,
    required this.alasan});
}

class DeleteDinasEvent extends DinasEvent {
  final int id;
  final int userId;

  const DeleteDinasEvent({required this.id, required this.userId});
}

