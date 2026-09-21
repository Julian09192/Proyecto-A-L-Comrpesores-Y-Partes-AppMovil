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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...productos.map((producto) {
                return Container(
                  width: 175,
                  height: 255, // 🚀 Altura optimizada y más compacta sin espacios sobrantes
                  margin: const EdgeInsets.only(right: 14, bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200, width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleProductoPage(
                              id: producto.id.toString(),
                              nombre: producto.nombre,
                              marca: producto.marca,
                              precio: '\$${producto.precio.toStringAsFixed(0)}',
                              imagenUrl: producto.imagenUrl ?? '',
                              descripcion: producto.caracteristicas.isNotEmpty
                                  ? producto.caracteristicas
                                  : 'Sin descripción técnica disponible.',
                            ),
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Contenedor de la Imagen
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15),
                            ),
                            child: Container(
                              height: 110,
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
                          
                          // Textos y contenido compacto
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    producto.marca.toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFFFDB913),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  SizedBox(
                                    height: 34, // Altura exacta para permitir hasta 2 líneas de texto limpias
                                    child: Text(
                                      producto.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: Color(0xFF0F2537),
                                        height: 1.2,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const Spacer(), // 🚀 Empuja el precio de manera fluida al fondo sin dejar espacios vacíos exagerados
                                  Text(
                                    '\$${producto.precio.toStringAsFixed(0)} COP',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 13.5,
                                      color: Color(0xFF222222),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                    width: 150,
                    height: 255, // Misma altura de 255 para mantener simetría total
                    margin: const EdgeInsets.only(right: 14, bottom: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDB913).withValues(alpha: 0.08),
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
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFDB913),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Ver más',
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F2537),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Catálogo completo',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
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