
import 'package:intl/intl.dart';

String formatTime(String? timeString) {
  if (timeString == null || timeString.isEmpty) return "-";

  try {
    // Parsing format dari database: HH:mm:ss.microseconds
    DateTime time = DateFormat("H:mm:ss.SSSSSS").parse(timeString);
    // Format output menjadi HH:mm
    return DateFormat("HH:mm").format(time);

  } catch (e) {
    return timeString;
  }
}

String formatDate(DateTime date) {
  return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
}