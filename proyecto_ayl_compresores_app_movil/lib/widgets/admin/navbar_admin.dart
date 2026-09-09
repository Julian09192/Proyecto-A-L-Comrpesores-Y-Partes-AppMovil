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
    final user = Supabase.instance.client.auth.currentUser;
    final nombre = AuthHelper.obtenerNombre(user);
    final email = user?.email ?? '';

    return Drawer(
      backgroundColor: const Color(0xFF1E1E24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.only(top: 50, bottom: 20, left: 20, right: 20),
            color: Colors.black26,
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.shield, color: Colors.black),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 11,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Administrador',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _itemMenu(
                  context: context,
                  icono: Icons.dashboard,
                  titulo: 'Dashboard',
                  activo: activeTitle == 'Dashboard',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Dashboard') {
                      Navigator.pushReplacementNamed(context, '/dashboard_admin');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.inventory_2,
                  titulo: 'Productos',
                  activo: activeTitle == 'Productos',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Productos') {
                      Navigator.pushReplacementNamed(context, '/admin_productos');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.book,
                  titulo: 'Bitácora',
                  activo: activeTitle == 'Bitácora',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Bitácora') {
                      Navigator.pushReplacementNamed(context, '/admin_bitacora');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.people,
                  titulo: 'Usuarios',
                  activo: activeTitle == 'Usuarios',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Usuarios') {
                      Navigator.pushReplacementNamed(context, '/admin_usuarios');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.bar_chart,
                  titulo: 'Reportes',
                  activo: activeTitle == 'Reportes',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Reportes') {
                      Navigator.pushReplacementNamed(context, '/admin_reportes');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.notifications,
                  titulo: 'Notificaciones',
                  activo: activeTitle == 'Notificaciones',
                  onTap: () {
                    Navigator.pop(context);
                    if (activeTitle != 'Notificaciones') {
                      Navigator.pushReplacementNamed(context, '/admin_notificaciones');
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.storefront,
                  titulo: 'Ver Tienda / Catálogo',
                  activo: false,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              Navigator.pop(context);
              await AuthHelper.cerrarSesion();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
              }
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _itemMenu({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    bool activo = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icono, color: activo ? Colors.amber : Colors.grey),
      title: Text(
        titulo,
        style: TextStyle(
          color: activo ? Colors.amber : Colors.grey,
          fontWeight: activo ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: activo ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
      onTap: onTap,
    );
  }
}
