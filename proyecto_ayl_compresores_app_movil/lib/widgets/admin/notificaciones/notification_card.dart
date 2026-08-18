import 'package:flutter/material.dart';

class NotificationCard extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool isNew = notification['isNew'] ?? false;
    final bool showImageText = notification['showImageText'] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 5,
                color: isNew ? const Color(0xFFF1A80A) : Colors.transparent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            showImageText ? 'EXAMPLE' : notification['initials'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: showImageText ? 8 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification['sku'] ?? '',
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              notification['title'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            RichText(
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                                children: [
                                  const TextSpan(
                                    text: 'Estado crítico: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'Solo quedan ',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                  TextSpan(
                                    text: '${notification['units']} unidades ',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const TextSpan(
                                    text: 'en inventario total.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                notification['date'] ?? '',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                              if (isNew) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1A80A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'NUEVA',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: onDelete,
                            child: const Text(
                              'Borrar',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}