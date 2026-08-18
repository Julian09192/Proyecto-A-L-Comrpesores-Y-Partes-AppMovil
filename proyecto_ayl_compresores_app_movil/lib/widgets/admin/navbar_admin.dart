import 'package:flutter/material.dart';
import '../../screens/admin/products_admin.dart';
import '../../screens/admin/notification_admin.dart';

class NavbarAdmin extends StatelessWidget {
  final String? currentRoute;

  const NavbarAdmin({
    super.key,
    this.currentRoute,
  });

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.pop(context); // Cierra el Drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  bool _isCurrentScreen(BuildContext context, Type screenType) {
    bool isMatch = false;
    context.visitAncestorElements((element) {
      if (element.widget.runtimeType == screenType) {
        isMatch = true;
        return false; // Detiene la búsqueda al encontrar la pantalla
      }
      return true;
    });
    return isMatch;
  }

  @override
  Widget build(BuildContext context) {
    // Determina la pantalla activa evaluando el árbol de widgets o el parámetro manual
    final isProductsSelected = currentRoute == '/products' || _isCurrentScreen(context, ProductsAdminScreen);
    final isNotificationsSelected = currentRoute == '/notifications' || _isCurrentScreen(context, NotificationAdminScreen);
    final isDashboardSelected = currentRoute == '/dashboard';
    final isBitacoraSelected = currentRoute == '/bitacora';
    final isUsersSelected = currentRoute == '/users';
    final isReportsSelected = currentRoute == '/reports';
    final isProfileSelected = currentRoute == '/profile';

    return Drawer(
      backgroundColor: const Color(0xFF111315),
      child: Column(
        children: [
          // Perfil de Usuario
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1D21),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Icon(Icons.phone_android, color: Colors.black),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Admin A&L',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1A80A),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Nivel Máster',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),

          // Items de Navegación
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildNavItem(
                  context,
                  Icons.speed,
                  'Dashboard',
                  isDashboardSelected,
                  onTap: () {},
                ),
                _buildNavItem(
                  context,
                  Icons.inventory_2_outlined,
                  'Productos',
                  isProductsSelected,
                  onTap: () {
                    if (!isProductsSelected) {
                      _navigateTo(context, const ProductsAdminScreen());
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  Icons.assignment_outlined,
                  'Bitácora',
                  isBitacoraSelected,
                  onTap: () {},
                ),
                _buildNavItem(
                  context,
                  Icons.people_outline,
                  'Usuario',
                  isUsersSelected,
                  onTap: () {},
                ),
                _buildNavItem(
                  context,
                  Icons.bar_chart_outlined,
                  'Reportes',
                  isReportsSelected,
                  onTap: () {},
                ),
                _buildNavItem(
                  context,
                  Icons.notifications_none_outlined,
                  'Notificaciones',
                  isNotificationsSelected,
                  badge: '5',
                  onTap: () {
                    if (!isNotificationsSelected) {
                      _navigateTo(context, const NotificationAdminScreen());
                    } else {
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildNavItem(
                  context,
                  Icons.settings_outlined,
                  'Mi Perfil',
                  isProfileSelected,
                  onTap: () {},
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white70),
            title: const Text(
              'Salir del Panel',
              style: TextStyle(color: Colors.white70),
            ),
            onTap: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    IconData icon,
    String title,
    bool isSelected, {
    String? badge,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1A80A) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.white70,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: badge != null
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badge,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}