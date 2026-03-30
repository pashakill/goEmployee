part of 'izin_bloc.dart';

abstract class IzinEvent extends Equatable {
  const IzinEvent();

  @override
  List<Object> get props => [];
}

class IzinFetchedEvent extends IzinEvent {
  final int userId;
  const IzinFetchedEvent({required this.userId});
}

class AddIzinEvent extends IzinEvent {
  final IzinConverterModel izinConverterModel;
  final int userId;
  final String izinTipe;
  final String tanggal;
  final String alasan;
  final String? jam;

  const AddIzinEvent(this.izinConverterModel, {required this.userId, required this.izinTipe, required this.alasan,
    required this.tanggal, required this.jam});
}

class EditIzinEvent extends IzinEvent {
  final IzinConverterModel izinConverterModel;
  final int userId;
  final String id;
  final String izinTipe;
  final String tanggal;
  final String alasan;
  final String? jam;

  const EditIzinEvent(this.izinConverterModel, {required this.userId, required this.izinTipe, required this.alasan,
    required this.tanggal, required this.id, required this.jam});
}


class DeleteIzinEvent extends IzinEvent {
  final int userId;
  final String id;

  const DeleteIzinEvent({required this.userId, required this.id});
}