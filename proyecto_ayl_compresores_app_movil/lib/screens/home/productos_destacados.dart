import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../productos/detail_product.dart';
import '../productos/productos_screen.dart';

class ProductosDestacados extends StatelessWidget {
  const ProductosDestacados({super.key, required this.futureProductos});

  final Future<List<ProductoModel>> futureProductos;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ProductoModel>>(
      future: futureProductos,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(30),
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        }

        final productosCrudos = snapshot.data ?? [];
        
        // 🚀 Filtramos para excluir cualquier producto suspendido
        final todosLosProductos = productosCrudos
            .where((producto) => !producto.suspendido)
            .toList();

        if (todosLosProductos.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('No hay productos disponibles por ahora.'),
          );
        }

        // Limitamos la lista a un máximo de 9 productos
        final productos = todosLosProductos.take(9).toList();
        final mostrarBotonVerMas = todosLosProductos.isNotEmpty;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              ...productos.map((producto) {
                return Container(
                  width: 175,
                  margin: const EdgeInsets.only(right: 14, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          color: const Color(0xFFF7F8FA),
                          child: (producto.imagenUrl != null &&
                                  producto.imagenUrl!.trim().isNotEmpty)
                              ? Image.network(
                                  producto.imagenUrl!.trim(),
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.amber.shade600,
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (_, _, _) => const Icon(
                                    Icons.image_not_supported_outlined,
                                    size: 38,
                                    color: Colors.black26,
                                  ),
                                )
                              : const Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 38,
                                  color: Colors.black26,
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.marca.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFFFDB913),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Color(0xFF222222),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${producto.precio.toStringAsFixed(0)} COP',
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Color(0xFF1E242B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 32,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFDB913),
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetalleProductoPage(
                                        nombre: producto.nombre,
                                        marca: producto.marca,
                                        precio:
                                            '\$${producto.precio.toStringAsFixed(0)}',
                                        imagenUrl: producto.imagenUrl ?? '',
                                        descripcion: producto
                                                .caracteristicas.isNotEmpty
                                            ? producto.caracteristicas
                                            : 'Sin descripción técnica disponible.',
                                      ),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'VER DETALLES',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }),
              
              // Tarjeta final "Ver más"
              if (mostrarBotonVerMas)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ProductsScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: 140,
                    height: 260,
                    margin: const EdgeInsets.only(right: 14, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDB913).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFFDB913),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDB913),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Ver más',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E242B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Catálogo completo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}