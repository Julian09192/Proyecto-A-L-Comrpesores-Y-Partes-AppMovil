import 'package:flutter/material.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../services/products/producto_service.dart';
import '../../models/products/producto_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ProductoService _productoService = ProductoService();
  List<ProductoModel> _productos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDashboard();
  }

  Future<void> _cargarDatosDashboard() async {
    setState(() => _cargando = true);
    try {
      final prods = await _productoService.getAll(soloActivos: false);
      if (!mounted) return;
      setState(() {
        _productos = prods;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalProductos = _productos.length;
    final int totalUnidades = _productos.fold(
      0,
      (sum, p) => sum + p.stockTotal,
    );
    final double valorInventario = _productos.fold(
      0.0,
      (sum, p) => sum + (p.stockTotal * p.precio),
    );
    final int alertasStock = _productos
        .where((p) => p.stockTotal <= 10 || p.suspendido)
        .length;
    final List<ProductoModel> ultimosProductos = _productos.take(10).toList();

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E1E24),
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
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
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (alertasStock > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        alertasStock > 9 ? '9+' : '$alertasStock',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            tooltip: 'Notificaciones',
            onPressed: () {
              Navigator.pushNamed(context, '/admin_notificaciones');
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sincronizar datos',
            onPressed: _cargarDatosDashboard,
          ),
        ],
      ),
      drawer: const NavbarAdmin(activeTitle: 'Dashboard'),
      body: RefreshIndicator(
        onRefresh: _cargarDatosDashboard,
        color: Colors.amber,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Principal de Control',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Últimas novedades del inventario y estado global del sistema',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),

              // Tarjetas de Métricas Clickables
              _construirTarjetasMetricas(
                totalProductos: totalProductos,
                totalUnidades: totalUnidades,
                valorInventario: valorInventario,
                alertasStock: alertasStock,
              ),

              const SizedBox(height: 25),

              // Accesos Rápidos a Todos los Módulos Admin
              const Text(
                'Módulos de Gestión',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _construirAccesosRapidos(),

              const SizedBox(height: 25),

              // Encabezado de Productos Recientes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Últimos productos agregados',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _cargando
                              ? 'Cargando inventario...'
                              : 'Mostrando ${ultimosProductos.length} recientes',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(6),
                    onTap: () {
                      Navigator.pushNamed(context, '/admin_productos');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 3),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Colors.amber,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Lista dinámica de productos
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(color: Colors.amber),
                  ),
                )
              else if (ultimosProductos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 48,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'No hay productos registrados aún',
                        style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/admin_productos'),
                        child: const Text(
                          'Ir a Productos Admin',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: ultimosProductos
                      .map((prod) => _construirItemProducto(prod))
                      .toList(),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- ACCESOS RÁPIDOS A MÓDULOS ---
  Widget _construirAccesosRapidos() {
    final modulos = [
      {
        'titulo': 'Productos',
        'subtitulo': 'Catálogo y Stock',
        'icono': Icons.inventory_2,
        'color': Colors.amber.shade700,
        'ruta': '/admin_productos',
      },
      {
        'titulo': 'Bitácora',
        'subtitulo': 'Auditoría y Cambios',
        'icono': Icons.book,
        'color': Colors.blueGrey.shade800,
        'ruta': '/admin_bitacora',
      },
      {
        'titulo': 'Reportes',
        'subtitulo': 'Métricas e Informes',
        'icono': Icons.bar_chart,
        'color': Colors.teal.shade700,
        'ruta': '/admin_reportes',
      },
      {
        'titulo': 'Notificaciones',
        'subtitulo': 'Alertas y Stock',
        'icono': Icons.notifications_active,
        'color': Colors.orange.shade700,
        'ruta': '/admin_notificaciones',
      },
      {
        'titulo': 'Usuarios',
        'subtitulo': 'Roles y Permisos',
        'icono': Icons.people,
        'color': Colors.indigo.shade700,
        'ruta': '/admin_usuarios',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: modulos.map((m) {
          return Container(
            width: 130,
            margin: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              elevation: 1,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  Navigator.pushNamed(context, m['ruta'] as String);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: (m['color'] as Color).withValues(
                          alpha: 0.12,
                        ),
                        child: Icon(
                          m['icono'] as IconData,
                          size: 20,
                          color: m['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        m['titulo'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['subtitulo'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 10,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // --- TARJETAS DE MÉTRICAS GLOBALES ---
  Widget _construirTarjetasMetricas({
    required int totalProductos,
    required int totalUnidades,
    required double valorInventario,
    required int alertasStock,
  }) {
    String formattedValor;
    if (valorInventario >= 1000000) {
      formattedValor = '\$${(valorInventario / 1000000).toStringAsFixed(1)}M';
    } else if (valorInventario >= 1000) {
      formattedValor = '\$${(valorInventario / 1000).toStringAsFixed(0)}K';
    } else {
      formattedValor = '\$${valorInventario.toStringAsFixed(0)}';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 10) / 2;
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _tarjeta(
              'CATÁLOGO GENERAL',
              _cargando ? '...' : '$totalProductos',
              Icons.inventory,
              Colors.amber,
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/admin_productos'),
            ),
            _tarjeta(
              'UNIDADES DISPONIBLES',
              _cargando ? '...' : '$totalUnidades',
              Icons.layers,
              Colors.black87,
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/admin_productos'),
            ),
            _tarjeta(
              'VALOR DEL INVENTARIO',
              _cargando ? '...' : formattedValor,
              Icons.attach_money,
              Colors.green.shade800,
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/admin_reportes'),
            ),
            _tarjeta(
              'ALERTAS DE STOCK',
              _cargando ? '...' : '$alertasStock',
              Icons.warning_amber_rounded,
              Colors.orange.shade800,
              itemWidth,
              onTap: () =>
                  Navigator.pushNamed(context, '/admin_notificaciones'),
            ),
          ],
        );
      },
    );
  }

  Widget _tarjeta(
    String titulo,
    String valor,
    IconData icono,
    Color colorIcono,
    double width, {
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 28,
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(icono, size: 20, color: colorIcono),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right,
                    size: 12,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- ITEM DE PRODUCTO REAL ---
  Widget _construirItemProducto(ProductoModel p) {
    final String codigo = p.codigoInterno ?? 'ID: #${p.id}';
    final bool esCritico = p.stockTotal <= 5;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () {
            Navigator.pushNamed(context, '/admin_productos');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Imagen o icono del producto
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            p.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2,
                          color: Colors.grey,
                          size: 24,
                        ),
                ),
                const SizedBox(width: 12),
                // Datos del producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.marca} • Ref: $codigo • ${p.stockTotal} und.',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge de estado
                if (p.suspendido)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Suspendido',
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else if (esCritico)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Stock Crítico',
                      style: TextStyle(
                        color: Colors.orange.shade900,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Activo',
                      style: TextStyle(
                        color: Colors.green.shade900,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
