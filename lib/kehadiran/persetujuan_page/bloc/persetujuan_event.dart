part of 'persetujuan_bloc.dart';

abstract class CutiEvent extends Equatable {
  const CutiEvent();

  @override
  List<Object> get props => [];
}

class PersetujuanFetchedEvent extends CutiEvent {
  final int userId;
  final String divisiId;
  final String role;
  const PersetujuanFetchedEvent({required this.userId, required this.divisiId, required this.role});
}

class ApprovePersetujuanEvent extends CutiEvent {
  final int userId;
  final String role;
  final String actions;
  final divisiId;

  const ApprovePersetujuanEvent({required this.userId, required this.role, required this.divisiId,
    required this.actions});
}
