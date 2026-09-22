import 'package:flutter/material.dart';
import '../../widgets/admin/navbar_admin.dart';
import '../../services/products/producto_service.dart';
import '../../services/notificaciones/notificacion_service.dart';
import '../../models/products/producto_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ProductoService _productoService = ProductoService();
  final NotificacionesService _notificacionesService = NotificacionesService();
  
  List<ProductoModel> _productos = [];
  int _notificacionesSinLeerCount = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDashboard();
  }

  Future<void> _cargarDatosDashboard() async {
    setState(() => _cargando = true);
    try {
      final results = await Future.wait([
        _productoService.getAll(soloActivos: false),
        _notificacionesService.obtenerNotificaciones(),
      ]);

      final prods = results[0] as List<ProductoModel>;
      final notificaciones = results[1] as List<Map<String, dynamic>>;

      final int sinLeer = notificaciones.where((n) => n['leido'] == false).length;

      if (!mounted) return;
      setState(() {
        _productos = prods;
        _notificacionesSinLeerCount = sinLeer;
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
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: const NavbarAdmin(activeTitle: 'Dashboard'),
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
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.notifications_outlined, color: Color(0xFF1E242B), size: 22),
                if (_notificacionesSinLeerCount > 0)
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
                        _notificacionesSinLeerCount > 9 ? '9+' : '$_notificacionesSinLeerCount',
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
            onPressed: () async {
              await Navigator.pushNamed(context, '/admin_notificaciones');
              _cargarDatosDashboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF1E242B), size: 22),
            tooltip: 'Sincronizar datos',
            onPressed: _cargarDatosDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatosDashboard,
        color: const Color(0xFFFDB913),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Principal de Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2537),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Últimas novedades del inventario y estado global del sistema',
                style: TextStyle(color: Color(0xFF7A837E), fontSize: 12, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),

              // Tarjetas de Métricas Estilizadas
              _construirTarjetasMetricas(
                totalProductos: totalProductos,
                totalUnidades: totalUnidades,
                valorInventario: valorInventario,
                alertasStock: alertasStock,
              ),

              const SizedBox(height: 24),

              // Accesos Rápidos (Sin Módulo de Usuarios)
              const Text(
                'Módulos de Gestión',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF0F2537)),
              ),
              const SizedBox(height: 12),
              _construirAccesosRapidos(),

              const SizedBox(height: 24),

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
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2537),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _cargando
                              ? 'Cargando inventario...'
                              : 'Mostrando ${ultimosProductos.length} recientes',
                          style: const TextStyle(
                            color: Color(0xFF7A837E),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
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
                              color: Color(0xFF222222),
                              fontWeight: FontWeight.w800,
                              fontSize: 12.5,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF222222),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Lista dinámica de productos recientes
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30.0),
                    child: CircularProgressIndicator(color: Color(0xFFFDB913)),
                  ),
                )
              else if (ultimosProductos.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                          color: Color(0xFF7A837E),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDB913),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, '/admin_productos'),
                        child: const Text(
                          'Ir a Productos Admin',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12.5),
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

  // --- ACCESOS RÁPIDOS A MÓDULOS DE EMPLEADO (SIN USUARIOS) ---
  Widget _construirAccesosRapidos() {
    final modulos = [
      {
        'titulo': 'Productos',
        'subtitulo': 'Catálogo y Stock',
        'icono': Icons.inventory_2_rounded,
        'color': const Color(0xFFFDB913),
        'ruta': '/admin_productos',
      },
      {
        'titulo': 'Bitácora',
        'subtitulo': 'Auditoría',
        'icono': Icons.book_rounded,
        'color': const Color(0xFF2C3238),
        'ruta': '/admin_bitacora',
      },
      {
        'titulo': 'Reportes',
        'subtitulo': 'Informes',
        'icono': Icons.bar_chart_rounded,
        'color': const Color(0xFF10B981),
        'ruta': '/admin_reportes',
      },
      {
        'titulo': 'Alertas',
        'subtitulo': 'Stock Bajo',
        'icono': Icons.notifications_active_rounded,
        'color': const Color(0xFFF97316),
        'ruta': '/admin_notificaciones',
      },
      {
        'titulo': 'Usuarios',
        'subtitulo': 'Roles',
        'icono': Icons.people_rounded,
        'color': const Color(0xFF6366F1),
        'ruta': '/admin_usuarios',
      },
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: modulos.map((m) {
          return Container(
            width: 125,
            margin: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pushNamed(context, m['ruta'] as String);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (m['color'] as Color).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          m['icono'] as IconData,
                          size: 20,
                          color: m['color'] as Color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        m['titulo'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF0F2537),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m['subtitulo'] as String,
                        style: const TextStyle(
                          color: Color(0xFF7A837E),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w500,
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
              Icons.inventory_2_rounded,
              const Color(0xFFFDB913),
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/admin_productos'),
            ),
            _tarjeta(
              'UNIDADES DISPONIBLES',
              _cargando ? '...' : '$totalUnidades',
              Icons.layers_rounded,
              const Color(0xFF222222),
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/empleado_productos'),
            ),
            _tarjeta(
              'VALOR DEL INVENTARIO',
              _cargando ? '...' : formattedValor,
              Icons.attach_money_rounded,
              const Color(0xFF10B981),
              itemWidth,
              onTap: () => Navigator.pushNamed(context, '/empleado_reportes'),
            ),
            _tarjeta(
              'ALERTAS DE STOCK',
              _cargando ? '...' : '$alertasStock',
              Icons.warning_amber_rounded,
              const Color(0xFFF97316),
              itemWidth,
              onTap: () async {
                await Navigator.pushNamed(context, '/empleado_notificaciones');
                _cargarDatosDashboard();
              },
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: width,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
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
                          color: Color(0xFF7A837E),
                          fontWeight: FontWeight.w800,
                          height: 1.25,
                        ),
                        maxLines: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorIcono.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icono, size: 18, color: colorIcono),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                valor,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2537),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(fontSize: 10.5, color: Color(0xFF7A837E), fontWeight: FontWeight.w600),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: Color(0xFF7A837E),
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
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.pushNamed(context, '/empleado_productos');
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F8FA),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                  ),
                  child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            p.imagenUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 22,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.inventory_2_outlined,
                          color: Color(0xFF7A837E),
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF0F2537),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p.marca} • Ref: $codigo • ${p.stockTotal} und.',
                        style: const TextStyle(
                          color: Color(0xFF7A837E),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (p.suspendido)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Suspendido',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Stock Crítico',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Activo',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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