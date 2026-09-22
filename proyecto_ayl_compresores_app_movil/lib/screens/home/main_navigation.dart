import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
import '../../services/products/cart_service.dart';
import '../../services/user/auth_helper.dart'; // Importante para obtener el nombre del usuario y cerrar sesión
import 'inicio_view.dart';
import '../productos/productos_screen.dart';
import '../cart/cart_screen.dart';
import 'settings.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final CartService _cartService = CartService();

  final List<Widget> _vistas = [
    const InicioView(),
    const ProductsScreen(),
    const LoginScreen(),
    const SettingsScreen(),
  ];

  final List<IconData> _iconos = [
    Icons.grid_view_rounded,
    Icons.inventory_2_outlined,
    Icons.person_rounded,
    Icons.settings_rounded,
  ];

  String _rolUsuario = '';

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_actualizarContador);
    _consultarRol();
  }

  Future<void> _consultarRol() async {
    final rol = await AuthHelper.obtenerRolUsuario();
    if (mounted) {
      setState(() {
        _rolUsuario = rol.toLowerCase();
      });
    }
  }

  @override
  void dispose() {
    _cartService.removeListener(_actualizarContador);
    super.dispose();
  }

  void _actualizarContador() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final int itemCount = _cartService.totalItemsCount;
    
    // 🚀 Verificamos el estado de sesión actual para el icono superior
    final currentUser = Supabase.instance.client.auth.currentUser;
    final nombreUsuario = currentUser != null ? AuthHelper.obtenerNombre(currentUser) : 'Invitado';
    final rol = _rolUsuario.isNotEmpty 
        ? _rolUsuario 
        : (currentUser != null ? AuthHelper.obtenerRol(currentUser).toLowerCase() : '');
    final bool esAdmin = rol == 'admin' || rol == 'administrador';
    final bool esEmpleado = rol == 'empleado';
    final bool esStaff = esAdmin || esEmpleado;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // 1. Contenido principal
          Positioned.fill(
            child: _vistas[_currentIndex],
          ),

          // 2. Barra Superior Fija Transparente con Logo, Perfil de Usuario y Carrito con Badge
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  height: 60 + topPadding,
                  padding: EdgeInsets.only(
                    top: topPadding,
                    left: 20,
                    right: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.55),
                        width: 1.0,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- LOGO (IMAGEN) ---
                      SizedBox(
                        height: 38,
                        child: Image.asset(
                          'assets/images/logo_ayl.png',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              Image.network(
                            'https://res.cloudinary.com/duvoqozcl/image/upload/v1777394217/logo-ayl.png',
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Text(
                                'A&L COMPRESORES',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF2C3238),
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // --- ACCIONES SUPERIORES (Staff pill + Usuario + Carrito) ---
                      Row(
                        children: [
                          if (esStaff) ...[
                            GestureDetector(
                              onTap: () {
                                if (esAdmin) {
                                  Navigator.pushNamedAndRemoveUntil(context, '/dashboard_admin', (route) => false);
                                } else {
                                  Navigator.pushNamedAndRemoveUntil(context, '/empleado_dashboard', (route) => false);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFDB913),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFFDB913).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      esAdmin ? Icons.admin_panel_settings_rounded : Icons.badge_rounded,
                                      size: 15,
                                      color: const Color(0xFF0F2537),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      esAdmin ? 'Panel Admin' : 'Panel Empleado',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F2537),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                          ],

                          // 🚀 Icono de Usuario con Menú Desplegable Flotante
                          IconButton(
                            icon: const Icon(
                              Icons.account_circle_outlined,
                              color: Color(0xFF2C3238),
                              size: 26,
                            ),
                            onPressed: () {
                              if (currentUser == null) {
                                setState(() => _currentIndex = 2);
                              } else {
                                final RenderBox renderBox = context.findRenderObject() as RenderBox;
                                final position = renderBox.localToGlobal(Offset.zero);
                                
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    position.dx + MediaQuery.of(context).size.width - 160, 
                                    65 + MediaQuery.of(context).padding.top, 
                                    20, 
                                    0,
                                  ),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  color: Colors.white,
                                  elevation: 8,
                                  items: [
                                    // 1. Cabecera con Datos del Usuario
                                    PopupMenuItem(
                                      enabled: false,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            nombreUsuario,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w900,
                                              fontSize: 15,
                                              color: Color(0xFF0F2537),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            currentUser.email ?? '',
                                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                          const Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Divider(height: 1),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // 🚀 Opción para volver al Panel si es Admin o Empleado
                                    if (esStaff)
                                      PopupMenuItem(
                                        onTap: () {
                                          if (esAdmin) {
                                            Navigator.pushNamedAndRemoveUntil(context, '/dashboard_admin', (route) => false);
                                          } else {
                                            Navigator.pushNamedAndRemoveUntil(context, '/empleado_dashboard', (route) => false);
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              esAdmin ? Icons.admin_panel_settings_rounded : Icons.badge_rounded, 
                                              size: 18, 
                                              color: const Color(0xFFFDB913),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              esAdmin ? 'Volver al Panel Admin' : 'Volver al Panel Empleado',
                                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F2537)),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // 2. Opción de Ver Perfil
                                    PopupMenuItem(
                                      onTap: () {
                                        setState(() => _currentIndex = 2);
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.person_outline_rounded, size: 18, color: Color(0xFF222222)),
                                          SizedBox(width: 10),
                                          Text(
                                            'Ver mi perfil',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF222222)),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // 🚀 3. Opción de Cerrar Sesión
                                    PopupMenuItem(
                                      onTap: () async {
                                        await AuthHelper.cerrarSesion();
                                        if (mounted) {
                                          setState(() {}); // Refresca la barra superior
                                        }
                                      },
                                      child: const Row(
                                        children: [
                                          Icon(Icons.logout_rounded, size: 18, color: Colors.redAccent),
                                          SizedBox(width: 10),
                                          Text(
                                            'Cerrar sesión',
                                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.redAccent),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 4),

                          // 🚀 Botón de Carrito con Badge Dinámico Integrado
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IconButton(
                                  splashRadius: 22,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(
                                    minWidth: 40,
                                    minHeight: 40,
                                  ),
                                  icon: const Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Color(0xFF2C3238),
                                    size: 25,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const CartScreen(),
                                      ),
                                    );
                                  },
                                ),
                                if (itemCount > 0)
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Colors.redAccent,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '$itemCount',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Barra Inferior Flotante Glass con Animación Deslizante
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            left: 20,
            right: 20,
            bottom: isKeyboardOpen 
                ? -100 
                : (bottomPadding > 0 ? bottomPadding + 6 : 18),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isKeyboardOpen ? 0.0 : 1.0,
              child: IgnorePointer(
                ignoring: isKeyboardOpen,
                child: Container(
                  height: 64,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(32),
                          color: Colors.white.withValues(alpha: 0.38),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.65),
                            width: 1.2,
                          ),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double itemWidth =
                                constraints.maxWidth / _iconos.length;

                            return Stack(
                              alignment: Alignment.centerLeft,
                              children: [
                                // Pastilla blanca animada
                                AnimatedPositioned(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.fastOutSlowIn,
                                  left: _currentIndex * itemWidth +
                                      (itemWidth - 54) / 2,
                                  child: Container(
                                    width: 54,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      borderRadius: BorderRadius.circular(22),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.06),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Fila de iconos interactivos
                                Row(
                                  children: List.generate(_iconos.length, (index) {
                                    final isSelected = _currentIndex == index;
                                    return Expanded(
                                      child: GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          setState(() {
                                            _currentIndex = index;
                                          });
                                        },
                                        child: SizedBox(
                                          height: 64,
                                          child: Center(
                                            child: AnimatedScale(
                                              scale: isSelected ? 1.15 : 1.0,
                                              duration:
                                                  const Duration(milliseconds: 250),
                                              child: Icon(
                                                _iconos[index],
                                                size: 22,
                                                color: isSelected
                                                    ? const Color(0xFF222222)
                                                    : const Color(0xFF7A837E),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}