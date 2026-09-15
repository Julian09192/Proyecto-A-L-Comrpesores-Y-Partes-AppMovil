import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
import '../../services/products/cart_service.dart'; // Asegúrate de ajustar la ruta de importación de tu CartService
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
  final CartService _cartService = CartService(); // 🚀 Instancia del servicio de carrito

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

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_actualizarContador); // 🚀 Escucha cambios en el carrito
  }

  @override
  void dispose() {
    _cartService.removeListener(_actualizarContador); // Limpia la escucha al destruir la vista
    super.dispose();
  }

  void _actualizarContador() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final int itemCount = _cartService.totalItemsCount; // 🚀 Total de elementos actual

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      extendBody: true,
      body: Stack(
        children: [
          // 1. Contenido principal
          Positioned.fill(
            child: _vistas[_currentIndex],
          ),

          // 2. Barra Superior Fija Transparente con Logo y Carrito con Badge Dinámico
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
                ),
              ),
            ),
          ),

          // 3. Barra Inferior Flotante Glass con Animación Deslizante
          Positioned(
            left: 20,
            right: 20,
            bottom: bottomPadding > 0 ? bottomPadding + 6 : 18,
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
        ],
      ),
    );
  }
}