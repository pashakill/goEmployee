import 'package:flutter/material.dart';

class DatePickerHelper {

  /// List tanggal merah (bisa nanti diganti dari API)
  static final List<DateTime> tanggalMerah = [
    DateTime(2026, 1, 1),
    DateTime(2026, 3, 22),
    DateTime(2026, 4, 18),
  ];

  /// Fungsi untuk cek apakah tanggal bisa dipilih
  static bool isSelectable(DateTime day) {
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return false;
    }

    for (var tgl in tanggalMerah) {
      if (day.year == tgl.year &&
          day.month == tgl.month &&
          day.day == tgl.day) {
        return false;
      }
    }

    return true;
  }

  /// Fungsi utama untuk show date picker
  static Future<DateTime?> pickDate(BuildContext context) async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      selectableDayPredicate: isSelectable,
      locale: const Locale('id', 'ID'),
    );
  }
}