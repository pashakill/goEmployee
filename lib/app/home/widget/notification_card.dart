import 'package:flutter/material.dart';
import 'package:goemployee/goemployee.dart';
import 'package:intl/intl.dart';

class NotificationCard extends StatelessWidget {
  final DataNotificationModels notificationModels;
  const NotificationCard({Key? key, required this.notificationModels}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range, size: 16, color: Colors.grey),
              const SizedBox(width: 6),
              Expanded(child: Text(
                notificationModels.createdAt,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),)
            ],
          ),

          const SizedBox(height: 8),
          Text(
            notificationModels.actorRole.toUpperCase(),
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            notificationModels.message,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
