import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';

class AttendanceTimeline extends StatelessWidget {
  final User user;

  const AttendanceTimeline({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String timeIn =
    (user.timeCheckin != null && user.timeCheckin!.isNotEmpty)
        ? user.timeCheckin!
        : '--:--';

    final String timeOut =
    (user.timeCheckout != null && user.timeCheckout!.isNotEmpty)
        ? user.timeCheckout!
        : '--:--';

    final String lateIn =
    (user.lateCheckin != null && user.lateCheckin!.isNotEmpty)
        ? user.lateCheckin!
        : '--:--';

    final List<Map<String, dynamic>> attendance = [
      {
        "title": "Check In",
        "time": timeIn,
        "icon": Icons.login_rounded,
        "color": Colors.green,
      },
      {
        "title": "Check Out",
        "time": timeOut,
        "icon": Icons.logout_rounded,
        "color": Colors.orange,
      },
      {
        "title": "Terlambat",
        "time": '${lateIn} menit',
        "icon": Icons.timer_off_rounded,
        "color": Colors.red,
      },
    ];

    return SizedBox(
      height: 135,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: attendance.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = attendance[index];

          return Container(
            width: 140,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade50,
              border: Border.all(
                color: Colors.grey.shade200,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                /// ================= ICON =================
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                    (item["color"] as Color).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    item["icon"],
                    color: item["color"],
                    size: 22,
                  ),
                ),

                const Spacer(),

                /// ================= TITLE =================
                Text(
                  item["title"],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 6),

                /// ================= TIME =================
                Text(
                  item["time"],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}