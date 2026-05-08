import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final DataNotificationModels notificationModels;

  const NotificationCard({
    Key? key,
    required this.notificationModels,
  }) : super(key: key);

  Color _roleColor(String role) {
    switch (role.toLowerCase()) {
      case 'manager':
        return Colors.blue;
      case 'hrd':
        return Colors.purple;
      case 'karyawan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = notificationModels.actorRole;
    final color = _roleColor(role);

    DateTime? parsedDate;
    try {
      parsedDate = DateTime.parse(notificationModels.createdAt);
    } catch (_) {}

    final formattedDate = parsedDate != null
        ? DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(parsedDate)
        : notificationModels.createdAt;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER (DATE + ROLE BADGE)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              /// DATE
              Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              /// ROLE BADGE
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  role.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /// MESSAGE
          Text(
            notificationModels.message,
            style: const TextStyle(
              fontSize: 13,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}