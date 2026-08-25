import 'package:flutter/material.dart';
import '../../services/products/cart_service.dart';
import '../cart/cart_screen.dart';

class DetalleProductoPage extends StatefulWidget {
  final String nombre;
  final String marca;
  final String precio;
  final String imagenUrl;
  final String descripcion;

  const DetalleProductoPage({
    super.key,
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

  // Convierte el texto de precio "\$890.000" a double
  double _parsePrecio(String precioStr) {
    final cleanStr = precioStr.replaceAll(RegExp(r'[^\d]'), '');
    return double.tryParse(cleanStr) ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final List<String> imagenes = [
      if (widget.imagenUrl.trim().isNotEmpty) widget.imagenUrl.trim(),
    ];

    final int cartCount = _cartService.totalItemsCount;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: Colors.amber,
              child: const Text(
                'COMPRESORES',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
                if (cartCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$cartCount',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 280,
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: imagenes.isNotEmpty
                          ? Image.network(
                              imagenes[_selectedImageIndex],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Center(
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
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Breadcrumb
            Row(
              children: [
                const Icon(Icons.home_outlined, size: 16, color: Colors.grey),
                const Text(' / ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(widget.marca, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // Badge
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

            // Nombre
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

            // Precio y Botón Agregar al Carrito
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
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        // Agregar al carrito
                        _cartService.addItem(
                          id: widget.nombre,
                          nombre: widget.nombre,
                          marca: widget.marca,
                          precio: _parsePrecio(widget.precio),
                          imagenUrl: widget.imagenUrl,
                        );

                        // Notificación visual al usuario
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('¡${widget.nombre} agregado al carrito!'),
                            duration: const Duration(seconds: 2),
                            backgroundColor: Colors.black87,
                            action: SnackBarAction(
                              label: 'VER CARRITO',
                              textColor: Colors.amber,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CartScreen()),
                                );
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black, size: 18),
                      label: const Text(
                        'Agregar al carrito',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Asesoría especializada
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

            // Descripción Técnica
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