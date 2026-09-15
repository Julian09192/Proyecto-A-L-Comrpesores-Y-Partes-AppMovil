import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
import '../../services/user/auth_helper.dart';
import '../../services/products/cart_service.dart';
import 'inicio_view.dart';
import 'nosotros_view.dart';
import 'contacto_view.dart';
import '../productos/productos_screen.dart';
import '../cart/cart_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_onCartUpdated);
  }

  @override
  void dispose() {
    _cartService.removeListener(_onCartUpdated);
    super.dispose();
  }

  void _onCartUpdated() {
    if (mounted) setState(() {});
  }

  void _irACatalogo() {
    setState(() {
      _currentIndex = 2; // Pestaña de Productos
    });
  }

  List<Widget> _obtenerVistas() {
    return [
      InicioView(onExplorarCatalogo: _irACatalogo),
      NosotrosView(onExplorarCatalogo: _irACatalogo),
      const ProductsScreen(),
      const ContactoView(),
    ];
  }

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
                    leading: const Icon(Icons.dashboard_rounded, color: Colors.black87),
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
    final int cartCount = _cartService.totalItemsCount;
    final vistas = _obtenerVistas();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222),
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
            tooltip: user != null ? 'Mi Cuenta' : 'Iniciar Sesión',
            icon: Icon(
              user != null ? Icons.account_circle : Icons.person_outline,
              color: user != null ? Colors.amber : Colors.white,
            ),
            onPressed: _abrirMenuUsuario,
          ),
          // Botón del Carrito de Compras con Badge de cantidad
          IconButton(
            tooltip: 'Carrito de compras',
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_cart,
                  color: Colors.amber,
                ),
                if (cartCount > 0)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartCount > 9 ? '9+' : '$cartCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
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
      body: vistas[_currentIndex],
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
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.info_outline_rounded), label: 'Nosotros'),
          BottomNavigationBarItem(icon: Icon(Icons.construction_rounded), label: 'Productos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_support_rounded),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }
}
