import 'package:flutter/material.dart';
import '../../screens/admin/admin_dashboard.dart';
import '../../screens/admin/admin_productos.dart';
import '../../screens/admin/admin_bitacora_view.dart';
import '../../screens/admin/admin_usuarios_view.dart';
import '../../screens/admin/admin_reportes_view.dart';
import '../../screens/admin/admin_notificaciones.dart';

class NavbarAdmin extends StatelessWidget {
  final String activeTitle;

  const NavbarAdmin({
    super.key,
    this.activeTitle = 'Dashboard',
  });

  @override
  Widget build(BuildContext context) {
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin A&L',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Nivel Máster',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminDashboard()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductsAdminScreen()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminBitacoraView()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminUsuariosView()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AdminReportesView()),
                      );
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationAdminScreen()),
                      );
                    }
                  },
                ),
                _itemMenu(
                  context: context,
                  icono: Icons.settings,
                  titulo: 'Mi Perfil',
                  activo: activeTitle == 'Mi Perfil',
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.redAccent),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.redAccent)),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
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
