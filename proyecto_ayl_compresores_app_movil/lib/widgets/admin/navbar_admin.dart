import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';

class NavbarAdmin extends StatelessWidget {
  final String activeTitle;

  const NavbarAdmin({
    super.key,
    this.activeTitle = 'Dashboard',
  });

  @override
  Widget build(BuildContext context) {
    // AQUÍ MANTENEMOS TU LÓGICA ORIGINAL INTACTA
    final user = Supabase.instance.client.auth.currentUser;
    final nombre = AuthHelper.obtenerNombre(user);
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: const Color(0xFF17171C), // Tono oscuro y elegante
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- CABECERA MODERNIZADA CON TUS DATOS REALES ---
            Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white10, width: 1)),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.amber, width: 2),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.white,
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'A',
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre.isNotEmpty ? nombre : 'Admin A&L', 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  if (email.isNotEmpty)
                    Text(
                      email,
                      style: const TextStyle(color: Colors.white60, fontSize: 11),
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.amber.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Administrador', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            
            // --- OPCIONES DEL MENÚ (Estilo Píldora) ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _itemMenu(context: context, icono: Icons.dashboard_rounded, titulo: 'Dashboard', ruta: '/dashboard_admin'),
                  _itemMenu(context: context, icono: Icons.inventory_2_rounded, titulo: 'Productos', ruta: '/admin_productos'),
                  _itemMenu(context: context, icono: Icons.book_rounded, titulo: 'Bitácora', ruta: '/admin_bitacora'),
                  _itemMenu(context: context, icono: Icons.people_alt_rounded, titulo: 'Usuarios', ruta: '/admin_usuarios'),
                  _itemMenu(context: context, icono: Icons.bar_chart_rounded, titulo: 'Reportes', ruta: '/admin_reportes'),
                  _itemMenu(context: context, icono: Icons.notifications_rounded, titulo: 'Notificaciones', ruta: '/admin_notificaciones'),
                  _itemMenu(context: context, icono: Icons.settings_rounded, titulo: 'Mi Perfil', ruta: '/admin_perfil'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(color: Colors.white12, height: 1),
                  ),
                  _itemMenu(context: context, icono: Icons.storefront_rounded, titulo: 'Ir a la Tienda', ruta: '/home'),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.exit_to_app_rounded),
                label: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold)),
                onPressed: () async {
                  Navigator.pop(context);
                  await AuthHelper.cerrarSesion(); // Tu lógica de cierre
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
    String? badge,
  }) {
    final bool activo = activeTitle == titulo;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: activo ? Colors.amber : Colors.transparent,
        leading: Icon(icono, color: activo ? Colors.black : Colors.grey.shade400, size: 22),
        title: Text(
          titulo, 
          style: TextStyle(
            color: activo ? Colors.black : Colors.grey.shade300, 
            fontWeight: activo ? FontWeight.bold : FontWeight.w500,
            fontSize: 14
          )
        ),
        trailing: badge != null 
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
              child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
            ) 
          : null,
        onTap: () {
          if (!activo) {
            Navigator.pop(context); // Cierra el drawer primero
            Navigator.pushReplacementNamed(context, ruta);
          }
        },
      ),
    );
  }
}