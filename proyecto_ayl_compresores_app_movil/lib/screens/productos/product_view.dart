import 'package:flutter/material.dart';
import 'detail_product.dart'; 
import '../home/main_navigation.dart';

class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Lista de productos (Simulando datos de Supabase)
    // Nota: Agregué la propiedad 'estado' para manejar la visibilidad
    final List<Map<String, dynamic>> productos = [
      {
        'categoria': 'TORNILLO',
        'nombre': 'ghhhhh',
        'tags': ['Flete guardia', 'Stock: 9'],
        'precio': '\$20000 COP',
        'estado': 'Activo', // Visible
      },
      {
        'categoria': 'ACEITE',
        'nombre': 'gf',
        'tags': ['efa', 'Stock: 0'],
        'precio': '\$32323 COP',
        'estado': 'Activo', // Visible
      },
      {
        'categoria': 'MOTOR',
        'nombre': 'Motor Dañado de Prueba',
        'tags': ['Generico', 'Stock: 0'],
        'precio': '\$0 COP',
        'estado': 'Suspendido', // 🚀 ESTE NO SE MOSTRARÁ
      },
      {
        'categoria': 'ACEITE',
        'nombre': 'Compresor 50L Actualizado',
        'tags': ['Generico', 'Stock: 8'],
        'precio': '\$20000 COP',
        'estado': 'Activo',
      },
      {
        'categoria': 'ACEITE',
        'nombre': 'Filtro Separador de Combustible FS-19732',
        'tags': ['Fleetguard', 'Stock: 8'],
        'precio': '\$185000 COP',
        'estado': 'Activo',
      }
    ];

    // 🚀 2. LÓGICA DE FILTRADO: Solo mantenemos los que NO están suspendidos
    final List<Map<String, dynamic>> productosVisibles = productos
        .where((producto) => producto['estado'] != 'Suspendido')
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      // 🚀 3. EL APPBAR: Esto empuja el contenido hacia abajo y evita que se tape
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            // Simulación de tu logo superior
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFDB913),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'A&L',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'COMPRESORES Y PARTES',
              style: TextStyle(
                color: Color(0xFFFDB913),
                fontWeight: FontWeight.w900,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black87),
            onPressed: () {
              // Acción de ir al carrito
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Buscador o Filtros Superiores (Scroll Horizontal)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                _buildFilterChip('Todos', isSelected: true),
                _buildFilterChip('Tornillo'),
                _buildFilterChip('Pistón'),
                _buildFilterChip('Aceite'),
                _buildFilterChip('Libres de Aire'),
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Equipos Destacados',
              style: TextStyle(
                fontSize: 16, 
                fontWeight: FontWeight.w800, 
                color: Color(0xFF0F2537)
              ),
            ),
          ),

          // Lista de Productos (usando la lista ya filtrada)
          Expanded(
            child: ListView.builder(
              // Padding inferior para que la barra flotante no tape el último ítem
              padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 110),
              itemCount: productosVisibles.length, // 🚀 Usamos la lista filtrada
              itemBuilder: (context, index) {
                final prod = productosVisibles[index];
                return _buildProductCard(context, prod);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget para los botones redondos superiores
  Widget _buildFilterChip(String label, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFDB913) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? const Color(0xFFFDB913) : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          if (isSelected) const Icon(Icons.check, size: 16, color: Colors.black87),
          if (isSelected) const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black87 : const Color(0xFF0F2537),
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // Widget de la tarjeta
  Widget _buildProductCard(BuildContext context, Map<String, dynamic> producto) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F5F7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 30),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      producto['categoria'],
                      style: const TextStyle(
                        color: Color(0xFFFDB913),
                        fontWeight: FontWeight.w900,
                        fontSize: 10,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Icon(Icons.favorite_border_rounded, color: Colors.grey, size: 20),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  producto['nombre'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Color(0xFF0F2537),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: (producto['tags'] as List<String>).map((tag) {
                    return Container(
                      margin: const EdgeInsets.only(right: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F5F7),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: Color(0xFF7A837E),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      producto['precio'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetalleProductoPage(
                              nombre: producto['nombre'],
                              marca: producto['tags'][0],
                              precio: producto['precio'],
                              imagenUrl: '',
                              descripcion: 'Descripción detallada',
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDB913),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'VER DETALLES',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}