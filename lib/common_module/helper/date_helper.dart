import 'package:intl/intl.dart';

class DateHelper {
  /// ==============================
  /// FORMAT
  /// ==============================
  static final DateFormat displayFormat =
  DateFormat('dd MMM yyyy HH:mm');

  static final DateFormat mysqlFormat =
  DateFormat('yyyy-MM-dd HH:mm:ss');

  /// ==============================
  /// BACKEND → LOCAL (WIB)
  /// ==============================
  static DateTime fromBackend(String dateString) {
    final parsed = DateTime.parse(dateString);

    // Jika dari backend UTC (Z) → convert ke local
    if (dateString.contains('Z')) {
      return parsed.toLocal();
    }

    // Jika dari MySQL (tanpa Z) → anggap UTC lalu convert
    return DateTime.utc(
      parsed.year,
      parsed.month,
      parsed.day,
      parsed.hour,
      parsed.minute,
      parsed.second,
    ).toLocal();
  }

  /// ==============================
  /// LOCAL → BACKEND (UTC, MYSQL FORMAT)
  /// ==============================
  static String toBackend(DateTime date) {
    return mysqlFormat.format(date.toUtc());
  }

  /// ==============================
  /// DISPLAY (UI)
  /// ==============================
  static String formatDisplay(DateTime date) {
    return displayFormat.format(date);
  }

  /// ==============================
  /// HITUNG DURASI (JAM)
  /// ==============================
  static int hitungDurasiJam(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 0;

    final minutes = end.difference(start).inMinutes.abs();
    return (minutes / 60).ceil();
  }

  /// ==============================
  /// HITUNG DURASI DETAIL
  /// ==============================
  static String hitungDurasiDetail(DateTime? start, DateTime? end) {
    if (start == null || end == null) return "-";

    final totalMinutes = end.difference(start).inMinutes.abs();
    final jam = totalMinutes ~/ 60;
    final menit = totalMinutes % 60;

    return "$jam jam $menit menit";
  }
}