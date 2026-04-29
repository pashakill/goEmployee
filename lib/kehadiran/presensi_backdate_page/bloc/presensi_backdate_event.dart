part of 'presensi_backdate_bloc.dart';

abstract class PresensiBackdateEvent extends Equatable {
  const PresensiBackdateEvent();

  @override
  List<Object> get props => [];
}

class PresensiBackdateFetchedEvent extends PresensiBackdateEvent {
  final int userId;
  const PresensiBackdateFetchedEvent({required this.userId});
}

class AddPresensiBackdateEvent extends PresensiBackdateEvent {
  final String berkas;
  final PresensiBackdateModel model;
  final String terlambat;
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String jam_mulai;
  final String jam_selesai;
  final String alasan;

  AddPresensiBackdateEvent(
      this.model, {
        required this.terlambat,
        required this.berkas,
        required this.userId,
        required this.kategori,
        required this.tanggal_mulai,
        required this.tanggal_selesai,
        required this.jam_mulai,
        required this.jam_selesai,
        required this.alasan,
      });
}


class EditPresensiBackdateEvent extends PresensiBackdateEvent {
  final PresensiBackdateModel presensiBackdateModel;
  final String pengajuanId;
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String jam_mulai;
  final String jam_selesai;
  final String alasan;

  EditPresensiBackdateEvent({
    required this.presensiBackdateModel,
    required this.pengajuanId,
    required this.userId,
    required this.kategori,
    required this.tanggal_mulai,
    required this.tanggal_selesai,
    required this.jam_mulai,
    required this.jam_selesai,
    required this.alasan,
  });
}

class DeletePresensiBackdateEvent extends PresensiBackdateEvent {
  final int pengajuanId;
  final int userId;
  const DeletePresensiBackdateEvent({required this.pengajuanId, required this.userId});
}

