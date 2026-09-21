import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:proyecto_ayl_compresores_app_movil/models/reportes/reporte_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/reporte/reporte_service.dart';
import '../../widgets/admin/navbar_admin.dart';

class AdminReportesView extends StatefulWidget {
  const AdminReportesView({super.key});

  @override
  State<AdminReportesView> createState() => _AdminReportesViewState();
}

class _AdminReportesViewState extends State<AdminReportesView> {
  ReporteInventarioResponse? _datosReporte;
  bool _cargando = true;

  // Filtros del Servidor
  final String _tipoReporte = 'stock';
  String _filtroCategoria = 'todas';
  String _filtroProveedor = 'todos';

  // Filtros Locales de la Tabla
  final TextEditingController _searchController = TextEditingController();
  String _filtroEstado = 'todos'; // todos, activos, suspendidos
  final String _filtroOrden = 'recientes'; // recientes, precio_menor, precio_mayor, stock_menor, stock_mayor

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _cargarReporte() async {
    setState(() => _cargando = true);
    try {
      final res = await ReporteService.obtenerInventario(
        tipoReporte: _tipoReporte,
        categoria: _filtroCategoria,
        proveedor: _filtroProveedor,
      );
      if (!mounted) return;
      setState(() {
        _datosReporte = res;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener reporte: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<ReporteProducto> _obtenerProductosProcesados() {
    if (_datosReporte == null) return [];
    final search = _searchController.text.toLowerCase().trim();

    final filtrados = _datosReporte!.productos.where((p) {
      final coincide = p.nombre.toLowerCase().contains(search) ||
          p.marca.toLowerCase().contains(search) ||
          p.codigoInterno.toLowerCase().contains(search) ||
          p.tipo.toLowerCase().contains(search);

      if (_filtroEstado == 'activos') return coincide && !p.suspendido;
      if (_filtroEstado == 'suspendidos') return coincide && p.suspendido;
      return coincide;
    }).toList();

    filtrados.sort((a, b) {
      if (_filtroOrden == 'precio_menor') return a.precio.compareTo(b.precio);
      if (_filtroOrden == 'precio_mayor') return b.precio.compareTo(a.precio);
      if (_filtroOrden == 'stock_menor') return a.stockTotal.compareTo(b.stockTotal);
      if (_filtroOrden == 'stock_mayor') return b.stockTotal.compareTo(a.stockTotal);
      return (b.id.toString()).compareTo(a.id.toString());
    });

    return filtrados;
  }

  // ==========================================
  // LÓGICA DE EXPORTACIÓN (CSV / EXCEL)
  // ==========================================

  void _exportarACSV(List<ReporteProducto> productos) {
    if (productos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay productos para exportar')),
      );
      return;
    }

    // Cabecera del archivo
    final StringBuffer csvBuffer = StringBuffer();
    // BOM UTF-8 para que Excel reconozca tildes y caracteres en español
    csvBuffer.write('\uFEFF');
    csvBuffer.writeln('Producto;Código Interno;Tipo;Marca;Precio;Stock Total;Estado');

    for (var p in productos) {
      final nombre = p.nombre.replaceAll(';', ',');
      final codigo = p.codigoInterno.replaceAll(';', ',');
      final tipo = p.tipo.replaceAll(';', ',');
      final marca = p.marca.replaceAll(';', ',');
      final precio = p.precio.toStringAsFixed(0);
      final stock = p.stockTotal.toString();
      final estado = p.suspendido ? 'Suspendido' : 'Activo';

      csvBuffer.writeln('$nombre;$codigo;$tipo;$marca;$precio;$stock;$estado');
    }

    final bytes = utf8.encode(csvBuffer.toString());
    final blob = html.Blob([bytes], 'text/csv;charset=utf-8');
    final url = html.Url.createObjectUrlFromBlob(blob);
    html.AnchorElement(href: url)
        ..setAttribute('download', 'reporte_inventario_${DateTime.now().millisecondsSinceEpoch}.csv')
        ..click();
    html.Url.revokeObjectUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Archivo CSV generado y descargado con éxito.'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productos = _obtenerProductosProcesados();
    final List<String> categoriasLista = [
      'todas',
      ...?_datosReporte?.categorias.map((c) => c.categoria),
    ];
    final List<String> proveedoresLista = [
      'todos',
      ...?_datosReporte?.proveedores,
    ];

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      drawer: const NavbarAdmin(activeTitle: 'Reportes'),
      appBar: AppBar(
        title: const Text('Reportes e Informes', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E24),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Exportar a CSV',
            onPressed: () => _exportarACSV(productos),
          ),
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Refrescar datos',
            onPressed: _cargarReporte,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
              onRefresh: _cargarReporte,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _construirPanelConfiguracion(categoriasLista, proveedoresLista),
                    const SizedBox(height: 16),
                    _construirResumenMetricas(),
                    const SizedBox(height: 16),
                    _construirGraficaCategorias(),
                    const SizedBox(height: 20),
                    _construirSeccionTablaProductos(productos),
                  ],
                ),
              ),
            ),
    );
  }

  String _formatearValorMonetario(double valor) {
    if (valor >= 1000000) {
      return '\$${(valor / 1000000).toStringAsFixed(1)}M';
    } else if (valor >= 1000) {
      return '\$${(valor / 1000).toStringAsFixed(0)}K';
    } else {
      return '\$${valor.toStringAsFixed(0)}';
    }
  }

  Widget _construirPanelConfiguracion(List<String> categorias, List<String> proveedores) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'CONFIGURACIÓN DEL REPORTE',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: categorias.contains(_filtroCategoria) ? _filtroCategoria : 'todas',
              decoration: InputDecoration(
                labelText: 'Filtrar por Categoría',
                prefixIcon: const Icon(Icons.category_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: categorias.toSet().map((cat) {
                return DropdownMenuItem(
                  value: cat,
                  child: Text(
                    cat == 'todas' ? 'Todas las categorías' : cat,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _filtroCategoria = val);
                  _cargarReporte();
                }
              },
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: proveedores.contains(_filtroProveedor) ? _filtroProveedor : 'todos',
              decoration: InputDecoration(
                labelText: 'Filtrar por Proveedor / Marca',
                prefixIcon: const Icon(Icons.business_outlined, size: 20),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              items: proveedores.toSet().map((prov) {
                return DropdownMenuItem(
                  value: prov,
                  child: Text(
                    prov == 'todos' ? 'Todos los proveedores' : prov,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _filtroProveedor = val);
                  _cargarReporte();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirResumenMetricas() {
    final resumen = _datosReporte?.resumen;
    return Row(
      children: [
        _tarjetaMetrica(
          'PRODUCTOS',
          '${resumen?.totalProductos ?? 0}',
          Colors.black87,
        ),
        const SizedBox(width: 8),
        _tarjetaMetrica(
          'STOCK TOTAL',
          '${resumen?.stockTotal ?? 0}',
          Colors.amber.shade800,
        ),
        const SizedBox(width: 8),
        _tarjetaMetrica(
          'VALOR INVENTARIO',
          _formatearValorMonetario(resumen?.valorTotal ?? 0.0),
          Colors.green.shade800,
        ),
      ],
    );
  }

  Widget _tarjetaMetrica(String titulo, String valor, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                valor,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirGraficaCategorias() {
    final categorias = _datosReporte?.categorias ?? [];
    int maxStock = 1;
    for (var c in categorias) {
      if (c.stockTotal > maxStock) maxStock = c.stockTotal;
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Stock por Categoría', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const Text('Distribución actual del inventario', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 16),
            categorias.isEmpty
                ? const Center(child: Text('No hay datos disponibles'))
                : Column(
                    children: categorias.map((cat) {
                      final porcentaje = (cat.stockTotal / maxStock).clamp(0.05, 1.0);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    cat.categoria,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text('${cat.stockTotal} und.', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: porcentaje,
                                minHeight: 8,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _construirSeccionTablaProductos(List<ReporteProducto> productos) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Productos del Reporte', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E1E24),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: const Icon(Icons.download_rounded, size: 16),
                  label: const Text('Exportar CSV', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  onPressed: () => _exportarACSV(productos),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Buscar por nombre, marca o tipo...',
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['todos', 'activos', 'suspendidos'].map((estado) {
                  final sel = _filtroEstado == estado;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(estado.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: sel ? Colors.white : Colors.black)),
                      selected: sel,
                      selectedColor: const Color(0xFF1E1E24),
                      onSelected: (_) => setState(() => _filtroEstado = estado),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            productos.isEmpty
                ? const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No hay productos con esos filtros')))
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                      columns: const [
                        DataColumn(label: Text('Producto', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Código', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tipo', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Precio', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Stock', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Estado', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: productos.map((p) {
                        return DataRow(cells: [
                          DataCell(Text(p.nombre, style: const TextStyle(fontWeight: FontWeight.w600))),
                          DataCell(Text(p.codigoInterno, style: const TextStyle(color: Colors.grey))),
                          DataCell(Text(p.tipo)),
                          DataCell(Text('\$${p.precio.toStringAsFixed(0)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
                          DataCell(Text('${p.stockTotal} und.')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: p.suspendido ? Colors.red.shade100 : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                p.suspendido ? 'Suspendido' : 'Activo',
                                style: TextStyle(color: p.suspendido ? Colors.red.shade900 : Colors.green.shade900, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}