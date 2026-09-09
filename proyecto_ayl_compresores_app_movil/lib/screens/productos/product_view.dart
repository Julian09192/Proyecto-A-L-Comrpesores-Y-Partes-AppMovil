import 'package:flutter/material.dart';
import 'detail_product.dart'; // Importa la vista de detalle

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
      appBar: AppBar(title: const Text('Productos')),
      body: ListView.builder(
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: Image.network(producto['imagenUrl']!, width: 50),
                title: Text(producto['nombre']!),
                subtitle: Text(producto['precio']!),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          );
        },
      ),
    );
  }
}