import 'package:flutter/material.dart';
import '../../services/notificaciones/notificacion_service.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../widgets/admin/notificaciones/notification_card.dart';

class NotificationAdminScreen extends StatefulWidget {
  const NotificationAdminScreen({super.key});

  @override
  State<NotificationAdminScreen> createState() => _NotificationAdminScreenState();
}

class _NotificationAdminScreenState extends State<NotificationAdminScreen> {
  bool _cargando = true;
  bool showUnreadOnly = false;
  
  final NotificacionesService _notificacionesService = NotificacionesService();
  List<Map<String, dynamic>> notifications = [];

  @override
  void initState() {
    super.initState();
    _cargarAlertasDesdeSupabase();
  }

  Future<void> _cargarAlertasDesdeSupabase() async {
    setState(() => _cargando = true);
    try {
      final data = await _notificacionesService.obtenerNotificaciones();
      
      final formattedNotifications = data.map((item) {
        final String nombreProd = item['nombre_producto'] ?? 'Producto sin nombre';
        final initials = nombreProd.trim().length >= 2
            ? nombreProd.trim().substring(0, 2).toUpperCase()
            : 'ST';
        
        final bool leido = item['leido'] ?? false;

        return {
          'id': item['id'].toString(),
          'initials': initials,
          'sku': 'PRODUCTO ID: #${item['producto_id'] ?? 'N/A'}',
          'title': nombreProd,
          'units': '${item['stock_registrado'] ?? 0}',
          'date': item['creado_en'] != null ? _formatearFecha(item['creado_en']) : 'Reciente',
          'isNew': !leido,
          'showImageText': false,
          'imagen_url': item['imagen_url'],
        };
      }).toList();

      if (mounted) {
        setState(() {
          notifications = formattedNotifications;
          _cargando = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al sincronizar alertas: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatearFecha(String fechaStr) {
    try {
      final fecha = DateTime.parse(fechaStr).toLocal();
      return '${fecha.day}/${fecha.month}/${fecha.year}, ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return fechaStr;
    }
  }

  // 🚀 Marcar todas como leídas en Supabase y actualizar estado local
  Future<void> _markAllAsRead() async {
    try {
      await _notificacionesService.marcarTodasComoLeidas();

      if (mounted) {
        setState(() {
          for (var notification in notifications) {
            notification['isNew'] = false;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Todas las notificaciones fueron marcadas como leídas'),
            backgroundColor: Colors.black87,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar estado: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _notificacionesService.eliminarNotificacion(id);
      if (mounted) {
        setState(() {
          notifications.removeWhere((item) => item['id'] == id);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al eliminar: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount = notifications.where((n) => n['isNew'] == true).length;
    final displayedNotifications = showUnreadOnly
        ? notifications.where((n) => n['isNew'] == true).toList()
        : notifications;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: const NavbarAdmin(activeTitle: 'Notificaciones'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E242B)),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: Color(0xFF1E242B),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFDB913),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          // 🚀 Botón directo en el AppBar para Marcar Todas como Leídas
          IconButton(
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFF1E242B), size: 22),
            tooltip: 'Marcar todas como leídas',
            onPressed: unreadCount > 0 ? _markAllAsRead : null,
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF1E242B), size: 22),
            tooltip: 'Sincronizar alertas',
            onPressed: _cargarAlertasDesdeSupabase,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFFDB913),
        onRefresh: _cargarAlertasDesdeSupabase,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- CABECERA ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Centro de Alertas',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2537),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Notificaciones de stock y sistema',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  // Botón de texto alternativo opcional
                  if (unreadCount > 0)
                    InkWell(
                      onTap: _markAllAsRead,
                      borderRadius: BorderRadius.circular(6),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        child: Text(
                          'Marcar leídas',
                          style: TextStyle(
                            color: const Color(0xFFFDB913).withValues(alpha: 0.9),
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),

              // --- PESTAÑAS (FILTROS) ---
              Row(
                children: [
                  _buildTab(
                    title: 'Todas',
                    isActive: !showUnreadOnly,
                    onTap: () => setState(() => showUnreadOnly = false),
                  ),
                  const SizedBox(width: 8),
                  _buildTab(
                    title: 'No leídas ($unreadCount)',
                    isActive: showUnreadOnly,
                    isAlert: unreadCount > 0,
                    onTap: () => setState(() => showUnreadOnly = true),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- LISTA DE NOTIFICACIONES ---
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFFFDB913)),
                  ),
                )
              else if (displayedNotifications.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.notifications_active_outlined,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Todo al día',
                        style: TextStyle(
                          color: Color(0xFF0F2537),
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No tienes notificaciones pendientes',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
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
      ),
    );
  }

  Widget _buildTab({required String title, required bool isActive, required VoidCallback onTap, bool isAlert = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF222222) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF222222) : Colors.black.withValues(alpha: 0.08),
          ),
          boxShadow: isActive
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAlert && isActive)
              Container(
                margin: const EdgeInsets.only(right: 6),
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: Color(0xFFFDB913), shape: BoxShape.circle),
              ),
            Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF555555),
                fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                fontSize: 12.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}