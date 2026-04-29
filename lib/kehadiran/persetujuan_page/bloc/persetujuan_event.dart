part of 'persetujuan_bloc.dart';

abstract class PersetujuanEvent extends Equatable {
  const PersetujuanEvent();

  @override
  List<Object> get props => [];
}

class PersetujuanFetchedEvent extends PersetujuanEvent {
  final int userId;
  final String divisiId;
  final String role;
  const PersetujuanFetchedEvent({required this.userId, required this.divisiId, required this.role});
}

class ApprovePersetujuanEvent extends PersetujuanEvent {
  final int pengajuanId;
  final String role;
  final String actions;
  final divisiId;
  final actor_id;

  const ApprovePersetujuanEvent({required this.pengajuanId, required this.role, required this.divisiId,
    required this.actions, required this.actor_id});
}
