import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
import '../../services/user/auth_helper.dart';
import 'inicio_view.dart';
import '../productos/productos_screen.dart';
import '../cart/cart_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _vistas = [
    const InicioView(),
    const Center(child: Text('Contenido de Nosotros')),
    const ProductsScreen(),
    const Center(child: Text('Contenido de Contactos')),
  ];

  Future<void> _abrirMenuUsuario() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      // Si no ha iniciado sesión, abrir la pantalla de Login
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      ).then((_) {
        // Al regresar, refrescar el estado por si inició sesión
        if (mounted) setState(() {});
      });
      return;
    }

    // Si ya tiene sesión iniciada, mostrar hoja de opciones de usuario
    final nombre = AuthHelper.obtenerNombre(user);
    final esAdmin = await AuthHelper.esAdmin(user: user);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (dialogContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.amber.shade100,
                  child: Icon(
                    esAdmin ? Icons.shield : Icons.person,
                    size: 35,
                    color: Colors.amber.shade900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  user.email ?? '',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: esAdmin ? Colors.black : Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    esAdmin ? 'ADMINISTRADOR' : 'CLIENTE',
                    style: TextStyle(
                      color: esAdmin ? Colors.amber : Colors.amber.shade900,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                if (esAdmin)
                  ListTile(
                    leading: const Icon(Icons.dashboard, color: Colors.black87),
                    title: const Text('Panel de Administración'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      Navigator.pushNamed(context, '/dashboard_admin');
                    },
                  ),
                ListTile(
                  leading: const Icon(Icons.exit_to_app, color: Colors.red),
                  title: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(dialogContext);
                    await AuthHelper.cerrarSesion();

                    if (mounted) {
                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Sesión cerrada correctamente'),
                          backgroundColor: Colors.black87,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      setState(() {});
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      // --- NUEVA BARRA SUPERIOR (AppBar) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222), // El color oscuro de tu marca
        elevation: 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'A&L',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Compresores',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          // Botón de Login / Usuario
          IconButton(
            icon: Icon(
              user != null ? Icons.account_circle : Icons.person_outline,
              color: user != null ? Colors.amber : Colors.white,
            ),
            onPressed: _abrirMenuUsuario,
          ),
          // Botón del Carrito de Compras
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.amber,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _vistas[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nosotros'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Productos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }
}
