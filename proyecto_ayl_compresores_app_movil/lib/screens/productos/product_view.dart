import 'package:flutter/material.dart';
import 'detail_product.dart'; // Importa la vista de detalle
import '../home/main_navigation.dart'; // Ajusta esta ruta según la ubicación de tu archivo main_navigation.dart

class ProductosPage extends StatelessWidget {
  const ProductosPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Ejemplo de lista de productos (puedes reemplazar esto por tu lista devuelta de la API/Supabase)
    final List<Map<String, String>> productos = [
      {
        'nombre': 'Aceite Sintético Shroyer ISO 46 Balde',
        'marca': 'SHROYER',
        'precio': '\$890.000 COP',
        'imagenUrl': 'https://via.placeholder.com/400x400',
        'descripcion': 'Consulta la información técnica, especificaciones y características del producto.',
      },
      {
        'nombre': 'Filtro para Compresor de Aire',
        'marca': 'AYL',
        'precio': '\$150.000 COP',
        'imagenUrl': 'https://via.placeholder.com/400x400',
        'descripcion': 'Filtro de alto rendimiento para mantenimiento.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Productos',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          // 🚀 Botón para saltar directamente a MainNavigation
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.black87),
            tooltip: 'Ir al menú principal',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: productos.length,
        itemBuilder: (context, index) {
          final producto = productos[index];

          return GestureDetector(
            onTap: () {
              // 🚀 NAVEGACIÓN HACIA EL DETALLE
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetalleProductoPage(
                    nombre: producto['nombre']!,
                    marca: producto['marca']!,
                    precio: producto['precio']!,
                    imagenUrl: producto['imagenUrl']!,
                    descripcion: producto['descripcion']!,
                  ),
                ),
              );
            },
            child: Card(
              elevation: 0.5,
              color: Colors.white,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    producto['imagenUrl']!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.image_not_supported_outlined,
                      size: 30,
                      color: Colors.grey,
                    ),
                  ),
                ),
                title: Text(
                  producto['nombre']!,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    producto['precio']!,
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}