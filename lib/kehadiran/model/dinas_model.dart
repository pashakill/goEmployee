import 'package:intl/intl.dart';

class DinasModel {

  final String tanggalMulai;
  final String tanggalSelesai;
  final String alamat;
  final String latitude;
  final String longTitude;
  final String radius;
  final String alasan;

  DinasModel({
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.alamat,
    required this.latitude,
    required this.longTitude,
    required this.radius,
    required this.alasan,
  });
}
