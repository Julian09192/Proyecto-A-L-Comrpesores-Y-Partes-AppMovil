import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';

class NavbarEmpleado extends StatelessWidget {
  final String activeTitle;

  const NavbarEmpleado({super.key, this.activeTitle = 'Dashboard'});

  static const String _rutaDashboard = '/empleado_dashboard';
  static const String _rutaProductos = '/empleado_productos';
  static const String _rutaBitacora = '/empleado_bitacora';
  static const String _rutaReportes = '/empleado_reportes';
  static const String _rutaNotificaciones = '/empleado_notificaciones';
  static const String _rutaPerfil = '/empleado_perfil';

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final nombre = AuthHelper.obtenerNombre(user);
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: const Color(
        0xFF17171C,
      ), // Tono oscuro y elegante corporativo
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABECERA CON DATOS DEL EMPLEADO ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.white10, width: 1),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFDB913),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre.isNotEmpty ? nombre : 'Empleado A&L',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 11.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDB913).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EMPLEADO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFFDB913),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // --- OPCIONES DEL MENÚ (Estilo Píldora Corporativa) ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _itemMenu(
                    context: context,
                    icono: Icons.dashboard_rounded,
                    titulo: 'Dashboard',
                    ruta: _rutaDashboard,
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.inventory_2_rounded,
                    titulo: 'Productos',
                    ruta: _rutaProductos,
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.book_rounded,
                    titulo: 'Bitácora',
                    ruta: _rutaBitacora,
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.bar_chart_rounded,
                    titulo: 'Reportes',
                    ruta: _rutaReportes,
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.notifications_rounded,
                    titulo: 'Notificaciones',
                    ruta: _rutaNotificaciones,
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.settings_rounded,
                    titulo: 'Mi Perfil',
                    ruta: _rutaPerfil,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  _itemMenu(
                    context: context,
                    icono: Icons.storefront_rounded,
                    titulo: 'Ir a la Tienda',
                    ruta: '/home',
                  ),
                ],
              ),
            ),

            // --- BOTÓN DE CERRAR SESIÓN ---
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  foregroundColor: Colors.redAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                onPressed: () async {
                  final confirmar = await showDialog<bool>(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text(
                        'Cerrar Sesión',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión en el sistema?',
                        style: TextStyle(fontSize: 13.5),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text(
                            'Cancelar',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text(
                            'Sí, cerrar sesión',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmar == true) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    await AuthHelper.cerrarSesion();
                    if (context.mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET REUTILIZABLE DE LA PÍLDORA ---
  Widget _itemMenu({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required String ruta,
  }) {
    final bool activo = activeTitle == titulo;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: activo ? const Color(0xFFFDB913) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icono,
          color: activo ? Colors.black : Colors.white70,
          size: 20,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: activo ? Colors.black : Colors.white,
            fontWeight: activo ? FontWeight.w900 : FontWeight.w500,
            fontSize: 13.5,
          ),
        ),
        onTap: () {
          if (!activo) {
            Navigator.pop(context);
            Navigator.pushReplacementNamed(context, ruta);
          } else {
            Navigator.pop(context);
          }
        },
      ),
    );
  }
}
