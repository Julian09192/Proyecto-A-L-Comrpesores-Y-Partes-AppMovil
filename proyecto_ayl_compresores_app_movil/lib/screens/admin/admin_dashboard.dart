import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/admin/navbar_admin.dart';
import 'admin_productos.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ProductoService _productoService = ProductoService();
  List<ProductoModel> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final data = await _productoService.getAll(soloActivos: false);
      if (!mounted) return;
      setState(() {
        _productos = data;
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

  String _formatearValor(double valor) {
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${valor.toStringAsFixed(0)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalProductos = _productos.length;
    final int totalUnidades = _productos.fold<int>(0, (sum, p) => sum + p.stockTotal);
    final double valorInventario = _productos.fold<double>(
      0.0,
      (sum, p) => sum + (p.precio * p.stockTotal),
    );
    final int alertasStock = _productos
        .where((p) => p.stockTotal <= 10 && !p.suspendido)
        .length;

    final List<ProductoModel> ultimosProductos = _productos.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
        title: const Text(
          'Panel de Control',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sincronizar datos',
            onPressed: _cargarDatos,
          )
        ],
      ),
      drawer: const NavbarAdmin(activeTitle: 'Dashboard'),
      body: _cargando
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.amber),
                  SizedBox(height: 12),
                  Text(
                    'Cargando inventario...',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 10),
                        const Text(
                          'Error al cargar los datos del dashboard',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                          ),
                          onPressed: _cargarDatos,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  color: Colors.amber,
                  onRefresh: _cargarDatos,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Últimas novedades del inventario y estado global',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        const SizedBox(height: 20),

                        // Tarjetas de Métricas Dinámicas
                        _construirTarjetasMetricas(
                          totalProductos: totalProductos,
                          totalUnidades: totalUnidades,
                          valorInventario: valorInventario,
                          alertasStock: alertasStock,
                        ),

                        const SizedBox(height: 30),

                        // Encabezado de Productos Recientes
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Últimos productos agregados',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Mostrando ${ultimosProductos.length} de $totalProductos productos',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ProductsAdminScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Ver todos',
                                style: TextStyle(
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Lista Real de Productos
                        _construirListaProductosReales(ultimosProductos),
                      ],
                    ),
                  ),
                ),
    );
  }

  // --- TARJETAS DE MÉTRICAS GLOBALES REALES ---
  Widget _construirTarjetasMetricas({
    required int totalProductos,
    required int totalUnidades,
    required double valorInventario,
    required int alertasStock,
  }) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _tarjeta(
          'CATÁLOGO GENERAL',
          '$totalProductos',
          Icons.inventory,
          Colors.amber,
        ),
        _tarjeta(
          'UNIDADES DISPONIBLES',
          '$totalUnidades',
          Icons.layers,
          Colors.black,
        ),
        _tarjeta(
          'VALOR DEL INVENTARIO',
          _formatearValor(valorInventario),
          Icons.attach_money,
          Colors.green.shade700,
        ),
        _tarjeta(
          'ALERTAS DE STOCK',
          '$alertasStock',
          Icons.warning_amber_rounded,
          alertasStock > 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }

  Widget _tarjeta(
    String titulo,
    String valor,
    IconData icono,
    Color colorIcono,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(icono, size: 20, color: colorIcono),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            valor,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // --- LISTA DE PRODUCTOS REALES ---
  Widget _construirListaProductosReales(List<ProductoModel> productos) {
    if (productos.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: const [
            Icon(Icons.inventory_2_outlined, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text(
              'No hay productos registrados en el inventario',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: productos.map((producto) {
        // Determinar badge según estado y stock
        Color badgeBg = Colors.black;
        String badgeText = 'Disponible';

        if (producto.suspendido) {
          badgeBg = Colors.red.shade700;
          badgeText = 'Suspendido';
        } else if (producto.stockTotal <= 5) {
          badgeBg = Colors.red.shade700;
          badgeText = 'Stock Crítico';
        } else if (producto.stockTotal <= 10) {
          badgeBg = Colors.orange.shade800;
          badgeText = 'Bajo Stock';
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Imagen del producto
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 50,
                  height: 50,
                  color: Colors.grey.shade100,
                  child: producto.imagenUrl != null &&
                          producto.imagenUrl!.isNotEmpty
                      ? Image.network(
                          producto.imagenUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 24,
                          ),
                        )
                      : Center(
                          child: Text(
                            producto.marca.isNotEmpty
                                ? producto.marca.substring(0, 1).toUpperCase()
                                : 'P',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),

              // Detalles del producto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      producto.nombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Ref: ${producto.codigoInterno ?? 'ID: #${producto.id}'}  •  ${producto.stockTotal} und.',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    Text(
                      '\$${producto.precio.toStringAsFixed(0)} COP',
                      style: TextStyle(
                        color: Colors.green.shade800,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge de estado
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}