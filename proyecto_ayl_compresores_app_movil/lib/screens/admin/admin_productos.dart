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

  int _filtroSeleccionadoIndex = 0;
  final List<Map<String, dynamic>> _opcionesFiltro = [
    {'titulo': 'Todos', 'icono': Icons.grid_view_rounded},
    {'titulo': 'Recientes', 'icono': Icons.access_time_rounded},
    {'titulo': 'Menor Precio', 'icono': Icons.arrow_upward_rounded},
    {'titulo': 'Mayor Precio', 'icono': Icons.arrow_downward_rounded},
    {'titulo': 'Suspendidos', 'icono': Icons.visibility_off_outlined},
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
        _aplicarFiltrosYBusqueda(_searchController.text);
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

  void _aplicarFiltrosYBusqueda(String query) {
    final q = query.trim().toLowerCase();

    List<ProductoModel> temporal = _todosLosProductos.where((p) {
      final nombre = p.nombre.toLowerCase();
      final marca = p.marca.toLowerCase();
      final codigo = (p.codigoInterno ?? '').toLowerCase();
      final tipo = p.tipo.toLowerCase();
      return nombre.contains(q) ||
          marca.contains(q) ||
          codigo.contains(q) ||
          tipo.contains(q);
    }).toList();

    switch (_filtroSeleccionadoIndex) {
      case 2: // Menor Precio
        temporal.sort((a, b) => a.precio.compareTo(b.precio));
        break;
      case 3: // Mayor Precio
        temporal.sort((b, a) => a.precio.compareTo(b.precio));
        break;
      case 4: // Suspendidos
        temporal = temporal.where((p) => p.suspendido).toList();
        break;
      default:
        break;
    }

    setState(() {
      _productosFiltrados = temporal;
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
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: const NavbarAdmin(activeTitle: 'Productos'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Color(0xFF1E242B)),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: Color(0xFF1E242B),
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFFDB913),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF1E242B), size: 22),
            tooltip: 'Sincronizar',
            onPressed: _cargarProductos,
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Contenido principal desplazable con margen inferior para que no lo tape la barra flotante
          RefreshIndicator(
            color: const Color(0xFFFDB913),
            onRefresh: _cargarProductos,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16, 16, 16, bottomPadding + 90),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inventario General',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2537),
                        ),
                      ),
                      Text(
                        '${_todosLosProductos.length} productos',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7A837E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Sistema de Filtros Horizontales (Chips modernos)
                  SizedBox(
                    height: 38,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _opcionesFiltro.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final bool isSelected = _filtroSeleccionadoIndex == index;
                        final filtro = _opcionesFiltro[index];
                        return InkWell(
                          onTap: () {
                            setState(() {
                              _filtroSeleccionadoIndex = index;
                            });
                            _aplicarFiltrosYBusqueda(_searchController.text);
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF222222) : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF222222) : Colors.black.withValues(alpha: 0.08),
                              ),
                              boxShadow: isSelected
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  filtro['icono'] as IconData,
                                  size: 15,
                                  color: isSelected ? const Color(0xFFFDB913) : const Color(0xFF555555),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  filtro['titulo'] as String,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFFFDB913) : const Color(0xFF555555),
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contenido / Carga / Listado
                  if (_cargando)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40.0),
                      child: Center(
                        child: CircularProgressIndicator(color: Color(0xFFFDB913)),
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
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF222222)),
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
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _productosFiltrados.length,
                      itemBuilder: (context, index) {
                        final producto = _productosFiltrados[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
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

          // 2. Barra inferior flotante con Buscador y el Botón Amarillo al lado
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomPadding > 0 ? bottomPadding + 6 : 16,
            child: Row(
              children: [
                // Barra de búsqueda ergonómica inferior
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: _aplicarFiltrosYBusqueda,
                      decoration: InputDecoration(
                        hintText: 'Buscar producto o ref...',
                        hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade400, fontWeight: FontWeight.w500),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF7A837E), size: 20),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, color: Colors.grey, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  _aplicarFiltrosYBusqueda('');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Botón Amarillo "Nuevo Producto" al lado del buscador
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB913),
                      foregroundColor: Colors.black87,
                      elevation: 4,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => EditProduct(
                          onSaved: _cargarProductos,
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_rounded, size: 20),
                    label: const Text(
                      'Nuevo',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}