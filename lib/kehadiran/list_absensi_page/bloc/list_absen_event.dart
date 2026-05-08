part of 'list_absen_bloc.dart';

abstract class ListAbsenEvent extends Equatable {
  const ListAbsenEvent();

  @override
  List<Object> get props => [];
}

class ListAbsenFetchedEvent extends ListAbsenEvent {
  final String? userId;
  final String from;
  final String to;
  final String status;

  ListAbsenFetchedEvent({this.userId, required this.from, required this.to, required this.status});
}
