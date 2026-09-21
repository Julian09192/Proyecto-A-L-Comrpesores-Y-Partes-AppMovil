import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/products/cart_service.dart';
import '../cart/cart_screen.dart';

import './detalle_header.dart.dart';
import './detalle_bottom_bar.dart';

class DetalleProductoPage extends StatefulWidget {
  final String id;
  final String nombre;
  final String marca;
  final String precio;
  final String imagenUrl;
  final String descripcion;

  const DetalleProductoPage({
    super.key,
    required this.id,
    required this.nombre,
    required this.marca,
    required this.precio,
    required this.imagenUrl,
    required this.descripcion,
  });

  @override
  State<DetalleProductoPage> createState() => _DetalleProductoPageState();
}

class _DetalleProductoPageState extends State<DetalleProductoPage> {
  final int _selectedImageIndex = 0;
  final CartService _cartService = CartService();

  @override
  void initState() {
    super.initState();
    _cartService.addListener(_updateBadge);
  }

  @override
  void dispose() {
    _cartService.removeListener(_updateBadge);
    super.dispose();
  }

  void _updateBadge() {
    if (mounted) setState(() {});
  }

  double _parsePrecio(String precioStr) {
    final cleanStr = precioStr.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleanStr) ?? 0.0;
  }

  void _agregarAlCarrito() {
    final user = Supabase.instance.client.auth.currentUser;

    // 🚀 Si no hay sesión iniciada, mostramos modal y detenemos el flujo
    if (user == null) {
      _mostrarModalRegistroCarrito();
      return;
    }

    _cartService.addItem(
      id: widget.id,
      nombre: widget.nombre,
      marca: widget.marca,
      precio: _parsePrecio(widget.precio),
      imagenUrl: widget.imagenUrl,
    );

    _mostrarToastAnimado(context, '¡${widget.nombre} agregado al carrito!');
  }

  // 🚀 Modal para invitar al login si no tiene sesión
  void _mostrarModalRegistroCarrito() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDB913).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFDB913), size: 28),
              ),
              const SizedBox(height: 16),
              const Text(
                '¡Inicia sesión para cotizar!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F2537)),
              ),
              const SizedBox(height: 10),
              const Text(
                'Debes tener una cuenta activa para añadir equipos al carrito de compras y guardar tu pedido.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF7A837E), fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/login');
                  },
                  child: const Text(
                    'INICIAR SESIÓN / REGISTRO',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12.5),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Ahora no', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarToastAnimado(BuildContext context, String mensaje) {
    late OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _ToastAnimadoWidget(
        mensaje: mensaje,
        onDismissed: () {
          overlayEntry.remove();
        },
      ),
    );

    Overlay.of(context).insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final List<String> imagenes = [
      if (widget.imagenUrl.trim().isNotEmpty) widget.imagenUrl.trim(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                top: 60 + topPadding + 16,
                bottom: bottomPadding > 0 ? bottomPadding + 84 : 96,
                left: 16,
                right: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 280,
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        child: imagenes.isNotEmpty
                            ? Image.network(
                                imagenes[_selectedImageIndex],
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : const Center(
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
                      const Text(' / ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      Text(widget.marca, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      widget.marca.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.nombre,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Consulta la información técnica, especificaciones y características del producto.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Precio de referencia',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: const Text(
                                'REF: N/A',
                                style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              widget.precio,
                              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'COP',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Asesoría especializada',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Nuestro equipo puede ayudarte con información sobre compatibilidad, disponibilidad y características técnicas del producto.',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                        ),
                        const SizedBox(height: 12),
                        _buildCheckItem('Consulta disponibilidad'),
                        _buildCheckItem('Solicita asesoría técnica'),
                        _buildCheckItem('Recibe una cotización'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: ExpansionTile(
                      title: const Text(
                        'Descripción Técnica',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            widget.descripcion,
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          DetalleProductoHeader(
            onBackPress: () => Navigator.pop(context),
          ),

          DetalleProductoBottomBar(
            onMenuPress: _agregarAlCarrito,
            onCartButtonPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            itemCount: _cartService.totalItemsCount,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.amber),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ToastAnimadoWidget extends StatefulWidget {
  final String mensaje;
  final VoidCallback onDismissed;

  const _ToastAnimadoWidget({
    required this.mensaje,
    required this.onDismissed,
  });

  @override
  State<_ToastAnimadoWidget> createState() => _ToastAnimadoWidgetState();
}

class _ToastAnimadoWidgetState extends State<_ToastAnimadoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 85,
      left: 16,
      right: 16,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.82),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.mensaje,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _controller.reverse().then((_) {
                        widget.onDismissed();
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CartScreen()),
                      );
                    },
                    child: const Text(
                      'VER CARRITO',
                      style: TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}