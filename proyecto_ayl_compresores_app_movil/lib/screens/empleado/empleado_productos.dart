import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Definición de color rojo corporativo estándar y tonos de apoyo
const Color empleadoRojo = Color(0xFFDC2626);
const Color empleadoRojoClaro = Color(0xFFEF4444);
const Color empleadoFondo = Color(0xFFF7F8FA);
const Color empleadoTexto = Color(0xFF0F2537);
const Color empleadoTextoSecundario = Color(0xFF7A837E);

class EmpleadoProductos extends StatefulWidget {
  const EmpleadoProductos({super.key});

  @override
  State<EmpleadoProductos> createState() => _EmpleadoProductosState();
}

class _EmpleadoProductosState extends State<EmpleadoProductos> {
  final _service = ProductoService();
  final _search = TextEditingController();
  List<ProductoModel> _productos = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final productos = await _service.getAll(soloActivos: false);
      if (mounted) {
        setState(() {
          _productos = productos;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.toLowerCase().trim();
    final visibles = _productos
        .where(
          (p) =>
              p.nombre.toLowerCase().contains(query) ||
              p.marca.toLowerCase().contains(query) ||
              (p.codigoInterno ?? '').toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      backgroundColor: empleadoFondo,
      drawer: const NavbarEmpleado(activeTitle: 'Productos'),
      appBar: AppBar(
        title: const Text(
          'Inventario de Productos',
          style: TextStyle(
            color: empleadoTexto,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: empleadoTexto),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.sync_rounded, color: empleadoRojo),
            tooltip: 'Sincronizar inventario',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: empleadoRojo,
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Barra de búsqueda moderna con acento en rojo corporativo
            TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por producto, marca o referencia...',
                hintStyle: const TextStyle(color: empleadoTextoSecundario, fontSize: 13.5),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: empleadoRojo,
                  size: 22,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1.2,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: empleadoRojo, width: 1.8),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: empleadoRojo,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_error != null)
              _mensaje('No se pudo cargar el inventario.\n$_error')
            else if (visibles.isEmpty)
              _mensaje('No se encontraron productos registrados.')
            else
              ...visibles.map(_construirTarjetaProducto),
          ],
        ),
      ),
    );
  }

  Widget _mensaje(String text) => Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: empleadoTextoSecundario,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      );

  Widget _construirTarjetaProducto(ProductoModel p) {
    final bool esSuspendido = p.suspendido;
    final bool stockBajo = p.stockTotal <= 5 && !esSuspendido;

    final String estadoTexto = esSuspendido
        ? 'Suspendido'
        : stockBajo
        ? 'Stock Bajo'
        : 'Disponible';

    final Color estadoColor = esSuspendido
        ? empleadoRojo
        : stockBajo
        ? Colors.orange.shade800
        : Colors.green.shade700;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Miniatura del producto
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 70,
                height: 70,
                color: empleadoFondo,
                child: (p.imagenUrl != null && p.imagenUrl!.trim().isNotEmpty)
                    ? Image.network(
                        p.imagenUrl!.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: empleadoTextoSecundario,
                          size: 26,
                        ),
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        color: empleadoRojo,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Información detallada
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.marca.toUpperCase(),
                    style: const TextStyle(
                      color: empleadoRojo,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    p.nombre,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: empleadoTexto,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code_rounded,
                        size: 14,
                        color: empleadoTextoSecundario,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ref: ${p.codigoInterno ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: empleadoTextoSecundario,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.layers_outlined,
                        size: 14,
                        color: empleadoTextoSecundario,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${p.stockTotal} unds',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: empleadoTexto,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Indicador de estatus con color dinámico
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: estadoColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                estadoTexto,
                style: TextStyle(
                  color: estadoColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}