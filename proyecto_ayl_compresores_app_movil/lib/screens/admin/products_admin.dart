import 'package:flutter/material.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../widgets/admin/edit_product.dart';
import '../../widgets/admin/producto_card.dart';


class ProductsAdminScreen extends StatelessWidget {
  const ProductsAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Drawer / Menú Lateral Hamburguesa
      drawer: const NavbarAdmin(),
      // Barra Superior Fija
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1A80A),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'PANEL ADMIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado
            const Text(
              'Inventario General',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            const Text(
              'Control y administración global de productos en catálogo',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),

            // Barra de búsqueda
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, marca o ref...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Botón Nuevo Producto
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white, size: 18),
                label: const Text(
                  'Nuevo producto',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Lista de Tarjetas de Producto
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ProductoCard(
                    onEdit: () {
                      showDialog(
                        context: context,
                        builder: (context) => const EditProduct(),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
      // Botón flotante de WhatsApp
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF25D366),
        shape: const CircleBorder(),
        child: const Icon(Icons.chat_bubble, color: Colors.white),
      ),
    );
  }
}