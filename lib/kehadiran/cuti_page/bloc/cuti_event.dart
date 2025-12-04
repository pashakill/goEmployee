part of 'cuti_bloc.dart';

abstract class CutiEvent extends Equatable {
  const CutiEvent();

  @override
  List<Object> get props => [];
}

class CutiFetchedEvent extends CutiEvent {
  final int userId;
  const CutiFetchedEvent({required this.userId});
}

class AddCutiEvent extends CutiEvent {
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String alasan;
  final String berkas;
  final CutiModel cutiModel;

  const AddCutiEvent({required this.userId, required this.kategori,
    required this.tanggal_mulai, required this.tanggal_selesai, required this.alasan,
    required this.berkas, required this.cutiModel});
}
