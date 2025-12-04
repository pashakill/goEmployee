
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