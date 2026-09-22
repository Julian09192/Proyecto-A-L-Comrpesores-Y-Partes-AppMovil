import 'package:flutter/material.dart';

import '../../models/products/producto_model.dart';
import '../../services/notificaciones/notificacion_service.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Definición de color rojo corporativo estándar y tonos de apoyo
const Color empleadoRojo = Color(0xFFDC2626);
const Color empleadoRojoClaro = Color(0xFFEF4444);
const Color empleadoFondo = Color(0xFFF7F8FA);

const Color empleadoVerdeMetalico = Color(0xFF10B981);
const Color empleadoNaranjaAlerta = Color(0xFFF97316);

const Color _textoPrincipal = Color(0xFF0F2537);
const Color _textoSecundario = Color(0xFF7A837E);

const _rutaEmpleadoDashboard = '/empleado_dashboard';
const _rutaEmpleadoProductos = '/empleado_productos';
const _rutaEmpleadoBitacora = '/empleado_bitacora';
const _rutaEmpleadoReportes = '/empleado_reportes';
const _rutaEmpleadoNotificaciones = '/empleado_notificaciones';
const _rutaEmpleadoPerfil = '/empleado_perfil';

class EmpleadoDashboard extends StatefulWidget {
  const EmpleadoDashboard({super.key});

  @override
  State<EmpleadoDashboard> createState() => _EmpleadoDashboardState();
}

class _EmpleadoDashboardState extends State<EmpleadoDashboard> {
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
      final productos = results[0] as List<ProductoModel>;
      final notificaciones = results[1] as List<Map<String, dynamic>>;
      final sinLeer = notificaciones.where((n) => n['leido'] == false).length;

      if (!mounted) return;
      setState(() {
        _productos = productos;
        _notificacionesSinLeerCount = sinLeer;
        _cargando = false;
      });
    } catch (e) {
      debugPrint('Error cargando dashboard de empleado: $e');
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalProductos = _productos.length;
    final totalUnidades = _productos.fold<int>(
      0,
      (sum, producto) => sum + producto.stockTotal,
    );
    final valorInventario = _productos.fold<double>(
      0,
      (sum, producto) => sum + producto.stockTotal * producto.precio,
    );
    final alertasStock = _productos
        .where((producto) => producto.stockTotal <= 10 || producto.suspendido)
        .length;
    final ultimosProductos = _productos.take(10).toList();

    return Scaffold(
      backgroundColor: empleadoFondo,
      drawer: const NavbarEmpleado(activeTitle: 'Dashboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _textoPrincipal),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A&L',
              style: TextStyle(
                color: _textoPrincipal,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: empleadoRojo,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'EMPLEADO',
                style: TextStyle(
                  color: Colors.white,
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
                const Icon(
                  Icons.notifications_outlined,
                  size: 22,
                  color: _textoPrincipal,
                ),
                if (_notificacionesSinLeerCount > 0)
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      decoration: const BoxDecoration(
                        color: empleadoRojo,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        _notificacionesSinLeerCount > 9
                            ? '9+'
                            : '$_notificacionesSinLeerCount',
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
              await Navigator.pushNamed(context, _rutaEmpleadoNotificaciones);
              _cargarDatosDashboard();
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.sync_rounded,
              size: 22,
              color: _textoPrincipal,
            ),
            tooltip: 'Sincronizar datos',
            onPressed: _cargarDatosDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _cargarDatosDashboard,
        color: empleadoRojo,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Panel Principal de Control',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: _textoPrincipal,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Últimas novedades del inventario y estado global del sistema',
                style: TextStyle(
                  color: _textoSecundario,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              _construirTarjetasMetricas(
                totalProductos: totalProductos,
                totalUnidades: totalUnidades,
                valorInventario: valorInventario,
                alertasStock: alertasStock,
              ),
              const SizedBox(height: 24),
              const Text(
                'Módulos de Operación',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: _textoPrincipal,
                ),
              ),
              const SizedBox(height: 12),
              _construirAccesosRapidos(),
              const SizedBox(height: 24),
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
                            color: _textoPrincipal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _cargando
                              ? 'Cargando inventario...'
                              : 'Mostrando ${ultimosProductos.length} recientes',
                          style: const TextStyle(
                            color: _textoSecundario,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, _rutaEmpleadoProductos),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                    label: const Text('Ver todos'),
                    style: TextButton.styleFrom(
                      foregroundColor: empleadoRojo,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_cargando)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(30),
                    child: CircularProgressIndicator(color: empleadoRojo),
                  ),
                )
              else if (ultimosProductos.isEmpty)
                _construirEstadoVacio()
              else
                Column(
                  children: ultimosProductos
                      .map(_construirItemProducto)
                      .toList(),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirEstadoVacio() {
    return Container(
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
              color: _textoSecundario,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirAccesosRapidos() {
    final modulos = [
      (
        'Productos',
        'Catálogo y Stock',
        Icons.inventory_2_rounded,
        empleadoRojo,
        _rutaEmpleadoProductos,
      ),
      (
        'Bitácora',
        'Auditoría',
        Icons.book_rounded,
        const Color(0xFF2C3238),
        _rutaEmpleadoBitacora,
      ),
      (
        'Reportes',
        'Informes',
        Icons.bar_chart_rounded,
        empleadoVerdeMetalico,
        _rutaEmpleadoReportes,
      ),
      (
        'Alertas',
        'Stock Bajo',
        Icons.notifications_active_rounded,
        empleadoNaranjaAlerta,
        _rutaEmpleadoNotificaciones,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: modulos.map((modulo) {
          final (titulo, subtitulo, icono, color, ruta) = modulo;
          return Container(
            width: 125,
            margin: const EdgeInsets.only(right: 10),
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Navigator.pushNamed(context, ruta),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(icono, size: 20, color: color),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _textoPrincipal,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitulo,
                        style: const TextStyle(
                          color: _textoSecundario,
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

  Widget _construirTarjetasMetricas({
    required int totalProductos,
    required int totalUnidades,
    required double valorInventario,
    required int alertasStock,
  }) {
    final formattedValor = valorInventario >= 1000000
        ? '\$${(valorInventario / 1000000).toStringAsFixed(1)}M'
        : valorInventario >= 1000
        ? '\$${(valorInventario / 1000).toStringAsFixed(0)}K'
        : '\$${valorInventario.toStringAsFixed(0)}';

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
              empleadoRojo,
              itemWidth,
              () => Navigator.pushNamed(context, _rutaEmpleadoProductos),
            ),
            _tarjeta(
              'UNIDADES DISPONIBLES',
              _cargando ? '...' : '$totalUnidades',
              Icons.layers_rounded,
              const Color(0xFF2C3238),
              itemWidth,
              () => Navigator.pushNamed(context, _rutaEmpleadoProductos),
            ),
            _tarjeta(
              'VALOR DEL INVENTARIO',
              _cargando ? '...' : formattedValor,
              Icons.attach_money_rounded,
              empleadoVerdeMetalico,
              itemWidth,
              () => Navigator.pushNamed(context, _rutaEmpleadoReportes),
            ),
            _tarjeta(
              'ALERTAS DE STOCK',
              _cargando ? '...' : '$alertasStock',
              Icons.warning_rounded,
              empleadoNaranjaAlerta,
              itemWidth,
              () async {
                await Navigator.pushNamed(context, _rutaEmpleadoNotificaciones);
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
    double width,
    VoidCallback onTap,
  ) {
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
                          color: _textoSecundario,
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
                  color: _textoPrincipal,
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Text(
                    'Ver detalle',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: _textoSecundario,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 2),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 14,
                    color: _textoSecundario,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirItemProducto(ProductoModel producto) {
    final codigo = producto.codigoInterno ?? 'ID: #${producto.id}';
    final esCritico = producto.stockTotal <= 5;
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
          onTap: () => Navigator.pushNamed(context, _rutaEmpleadoProductos),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: empleadoFondo,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.04),
                    ),
                  ),
                  child:
                      producto.imagenUrl != null &&
                          producto.imagenUrl!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            producto.imagenUrl!,
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
                          color: _textoSecundario,
                          size: 22,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: _textoPrincipal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${producto.marca} • Ref: $codigo • ${producto.stockTotal} und.',
                        style: const TextStyle(
                          color: _textoSecundario,
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
                _estadoProducto(producto, esCritico),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _estadoProducto(ProductoModel producto, bool esCritico) {
    final texto = producto.suspendido
        ? 'Suspendido'
        : esCritico
        ? 'Stock Crítico'
        : 'Activo';
    final color = producto.suspendido
        ? empleadoRojo
        : esCritico
        ? empleadoNaranjaAlerta
        : empleadoVerdeMetalico;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}