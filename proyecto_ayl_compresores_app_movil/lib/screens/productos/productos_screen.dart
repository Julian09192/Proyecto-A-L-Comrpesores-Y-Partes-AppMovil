import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/product_card.dart';
import 'detail_product.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCategoryIndex = 0;
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureProductos;
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Todos',
    'Tornillo',
    'Pistón',
    'Aceite',
    'Libres de Aire',
  ];

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _cargarProductos() {
    final categoria = categories[_selectedCategoryIndex];
    setState(() {
      _futureProductos = _productoService.filterByParams(
        tipo: categoria == 'Todos' ? null : categoria,
        searchQuery: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => _cargarProductos(),
        color: Colors.amber,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Buscador
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _cargarProductos(),
                  decoration: const InputDecoration(
                    hintText: 'Buscar compresores, repuestos...',
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Icon(Icons.mic, color: Colors.amber),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categorías horizontales
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedCategoryIndex == index;
                    return ChoiceChip(
                      label: Text(categories[index]),
                      selected: isSelected,
                      selectedColor: Colors.amber,
                      backgroundColor: Colors.grey.shade100,
                      labelStyle: TextStyle(
                        color: Colors.black,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide.none,
                      ),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        _cargarProductos();
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'Equipos Destacados',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // FutureBuilder con Supabase
              FutureBuilder<List<ProductoModel>>(
                future: _futureProductos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Colors.amber),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text(
                              'Error: ${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _cargarProductos,
                              child: const Text('Reintentar', style: TextStyle(color: Colors.amber)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final productos = snapshot.data ?? [];

                  if (productos.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text(
                          'No se encontraron productos.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: productos.map((producto) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ProductoCard(
                          producto: producto,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleProductoPage(
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
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}