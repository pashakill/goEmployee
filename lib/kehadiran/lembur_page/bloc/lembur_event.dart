part of 'lembur_bloc.dart';

abstract class LemburEvent extends Equatable {
  const LemburEvent();

  @override
  List<Object> get props => [];
}

class LemburFetchedEvent extends LemburEvent {
  final int userId;
  const LemburFetchedEvent({required this.userId});
}

class AddLemburEvent extends LemburEvent {
  final int userId;
  final String kategori;
  final String tanggal_mulai;
  final String tanggal_selesai;
  final String durasi;
  final String alasan;
  final LemburModel lemburModel;

  const AddLemburEvent(this.lemburModel, {required this.userId, required this.kategori,
    required this.tanggal_mulai, required this.alasan, required this.tanggal_selesai,
    required this.durasi});
}
