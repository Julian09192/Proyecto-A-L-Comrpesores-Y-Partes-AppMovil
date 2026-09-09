import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../widgets/admin/Productos/edit_product.dart';
import '../../widgets/admin/Productos/product_card.dart';

class ProductsAdminScreen extends StatefulWidget {
  const ProductsAdminScreen({super.key});

  @override
  State<ProductsAdminScreen> createState() => _ProductsAdminScreenState();
}

class _ProductsAdminScreenState extends State<ProductsAdminScreen> {
  final ProductoService _productoService = ProductoService();
  final TextEditingController _searchController = TextEditingController();

  List<ProductoModel> _todosLosProductos = [];
  List<ProductoModel> _productosFiltrados = [];
  bool _cargando = true;
  String? _error;

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

  Future<void> _cargarProductos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final data = await _productoService.getAll(soloActivos: false);
      if (!mounted) return;
      setState(() {
        _todosLosProductos = data;
        _filtrar(_searchController.text);
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  void _filtrar(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _productosFiltrados = _todosLosProductos;
      } else {
        _productosFiltrados = _todosLosProductos.where((p) {
          final nombre = p.nombre.toLowerCase();
          final marca = p.marca.toLowerCase();
          final codigo = (p.codigoInterno ?? '').toLowerCase();
          final tipo = p.tipo.toLowerCase();
          return nombre.contains(q) ||
              marca.contains(q) ||
              codigo.contains(q) ||
              tipo.contains(q);
        }).toList();
      }
    });
  }

  Future<void> _toggleSuspension(ProductoModel producto) async {
    try {
      final actualizado = await _productoService.toggleSuspension(producto.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            actualizado.suspendido
                ? 'Producto "${producto.nombre}" suspendido'
                : 'Producto "${producto.nombre}" reactivado',
          ),
          backgroundColor:
              actualizado.suspendido ? Colors.red.shade800 : Colors.green.shade700,
        ),
      );
      _cargarProductos();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      // Drawer / Menú Lateral Hamburguesa
      drawer: const NavbarAdmin(activeTitle: 'Productos'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sincronizar',
            onPressed: _cargarProductos,
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(0xFFF1A80A),
        onRefresh: _cargarProductos,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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
              Text(
                'Control y administración global de productos (${_todosLosProductos.length} en total)',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),

              // Barra de búsqueda
              TextField(
                controller: _searchController,
                onChanged: _filtrar,
                decoration: InputDecoration(
                  hintText: 'Buscar por nombre, marca o ref...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _filtrar('');
                          },
                        )
                      : null,
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
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditProduct(
                        onSaved: _cargarProductos,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Nuevo producto',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Estado de carga / error / lista
              if (_cargando)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFFF1A80A)),
                  ),
                )
              else if (_error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 40),
                        const SizedBox(height: 8),
                        Text(
                          'Error: $_error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                          ),
                          onPressed: _cargarProductos,
                          child: const Text('Reintentar', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_productosFiltrados.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0),
                  child: Center(
                    child: Text(
                      'No se encontraron productos',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                )
              else
                // Lista de Tarjetas de Producto Reales
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _productosFiltrados.length,
                  itemBuilder: (context, index) {
                    final producto = _productosFiltrados[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ProductoCard(
                        producto: producto,
                        onEdit: () {
                          showDialog(
                            context: context,
                            builder: (context) => EditProduct(
                              producto: producto,
                              onSaved: _cargarProductos,
                            ),
                          );
                        },
                        onToggleSuspension: () => _toggleSuspension(producto),
                      ),
                    );
                  },
                ),
            ],
          ),
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