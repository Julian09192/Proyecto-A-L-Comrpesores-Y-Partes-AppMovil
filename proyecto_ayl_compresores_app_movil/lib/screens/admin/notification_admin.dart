import 'package:flutter/material.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../widgets/admin/notificaciones/notification_header.dart';
import '../../widgets/admin/notificaciones/notification_filter_tabs.dart';
import '../../widgets/admin/notificaciones/notification_card.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() => _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      'id': '1',
      'initials': 'FI',
      'sku': 'SKU ID: #28',
      'title': 'Filtro Separador de Combustible FS-19732',
      'units': '10',
      'date': '3/7/2026, 5:03:58 p.m.',
      'isNew': true,
      'showImageText': false,
    },
    {
      'id': '2',
      'initials': 'FI',
      'sku': 'SKU ID: #28',
      'title': 'Filtro Separador de Combustible FS-19732',
      'units': '8',
      'date': '3/7/2026, 4:58:52 p.m.',
      'isNew': true,
      'showImageText': false,
    },
    {
      'id': '3',
      'initials': 'AC',
      'sku': 'SKU ID: #26',
      'title': 'Aceite Ejemplo ejemplo de sustentacion',
      'units': '5',
      'date': '2/7/2026, 8:52:36 a.m.',
      'isNew': true,
      'showImageText': false,
    },
    {
      'id': '4',
      'initials': 'AC',
      'sku': 'SKU ID: #26',
      'title': 'Aceite Ejemplo ejemplo de sustentacion',
      'units': '10',
      'date': '2/7/2026, 8:51:50 a.m.',
      'isNew': true,
      'showImageText': false,
    },
    {
      'id': '5',
      'initials': 'EX',
      'sku': 'SKU ID: #25',
      'title': 'Aceite Ejemplo Premium 10W40',
      'units': '8',
      'date': '30/6/2026, 9:47:15 p.m.',
      'isNew': true,
      'showImageText': true,
    },
  ];

  bool showUnreadOnly = false;

  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['isNew'] = false;
      }
    });
  }

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((item) => item['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['isNew'] == true).length;
    final displayedNotifications = showUnreadOnly
        ? notifications.where((n) => n['isNew'] == true).toList()
        : notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const NavbarAdmin(),
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1A80A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PANEL ADMIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            NotificationHeader(onMarkAllAsRead: _markAllAsRead),
            const SizedBox(height: 20),
            NotificationFilterTabs(
              showUnreadOnly: showUnreadOnly,
              unreadCount: unreadCount,
              onTabChanged: (unreadOnly) {
                setState(() => showUnreadOnly = unreadOnly);
              },
            ),
            const SizedBox(height: 16),
            if (displayedNotifications.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Center(
                  child: Text(
                    'No hay notificaciones para mostrar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...displayedNotifications.map((item) {
                return NotificationCard(
                  notification: item,
                  onDelete: () => _deleteNotification(item['id']),
                );
              }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }
}