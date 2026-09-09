import 'package:flutter/material.dart';

class NotificationFilterTabs extends StatelessWidget {
  final bool showUnreadOnly;
  final int unreadCount;
  final ValueChanged<bool> onTabChanged;

  const NotificationFilterTabs({
    super.key,
    required this.showUnreadOnly,
    required this.unreadCount,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => onTabChanged(false),
              child: Text(
                'Historial Completo',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: !showUnreadOnly ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => onTabChanged(true),
              child: Text(
                'Sin Revisar ($unreadCount)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: showUnreadOnly ? Colors.black : Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: Colors.grey[300], height: 1),
      ],
    );
  }
}