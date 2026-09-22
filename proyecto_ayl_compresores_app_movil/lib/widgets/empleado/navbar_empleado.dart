import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';

// 🚀 Definición de color rojo corporativo estándar y tonos limpios
const Color empleadoRojo = Color(0xFFDC2626);
const Color empleadoRojoClaro = Color(0xFFEF4444);
const Color empleadoTexto = Color(0xFF0F2537);
const Color empleadoTextoSecundario = Color(0xFF7A837E);

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
      // 🎨 Fondo blanco limpio y profesional
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: empleadoRojo,
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: empleadoRojo.withValues(alpha: 0.1),
                      child: Text(
                        nombre.isNotEmpty ? nombre[0].toUpperCase() : 'E',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: empleadoRojo,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    nombre.isNotEmpty ? nombre : 'Empleado A&L',
                    style: const TextStyle(
                      color: empleadoTexto,
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
                        color: empleadoTextoSecundario,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
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
                      color: empleadoRojo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'EMPLEADO ACTIVO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: empleadoRojo,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _itemMenu(
                    context,
                    Icons.dashboard_rounded,
                    'Dashboard',
                    _rutaDashboard,
                  ),
                  _itemMenu(
                    context,
                    Icons.inventory_2_rounded,
                    'Productos',
                    _rutaProductos,
                  ),
                  _itemMenu(
                    context,
                    Icons.book_rounded,
                    'Bitácora',
                    _rutaBitacora,
                  ),
                  _itemMenu(
                    context,
                    Icons.bar_chart_rounded,
                    'Reportes',
                    _rutaReportes,
                  ),
                  _itemMenu(
                    context,
                    Icons.notifications_rounded,
                    'Notificaciones',
                    _rutaNotificaciones,
                  ),
                  _itemMenu(
                    context,
                    Icons.settings_rounded,
                    'Mi Perfil',
                    _rutaPerfil,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: empleadoRojo.withValues(alpha: 0.1),
                  foregroundColor: empleadoRojo,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.exit_to_app_rounded, size: 18),
                label: const Text(
                  'Cerrar Sesión',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
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
                          color: empleadoTexto,
                        ),
                      ),
                      content: const Text(
                        '¿Estás seguro de que deseas cerrar sesión en el sistema?',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: empleadoTextoSecundario,
                        ),
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
                              color: empleadoTextoSecundario,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: empleadoRojo,
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
                        '/inicio', // Redirige a inicio_view
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

  Widget _itemMenu(
    BuildContext context,
    IconData icono,
    String titulo,
    String ruta,
  ) {
    final activo = activeTitle == titulo;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: activo ? empleadoRojo : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        leading: Icon(
          icono,
          color: activo ? Colors.white : empleadoTextoSecundario,
          size: 20,
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: activo ? Colors.white : empleadoTexto,
            fontWeight: activo ? FontWeight.w900 : FontWeight.w600,
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