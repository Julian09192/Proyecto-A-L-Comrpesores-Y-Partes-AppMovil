import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/bitacora/bitacora_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/bitacora/bitacora_service.dart';

class AdminBitacoraView extends StatefulWidget {
  const AdminBitacoraView({super.key});

  @override
  State<AdminBitacoraView> createState() => _AdminBitacoraViewState();
}

class _AdminBitacoraViewState extends State<AdminBitacoraView> {
  List<MovimientoBitacora> movimientos = [];
  List<MovimientoBitacora> movimientosFiltrados = [];
  bool isLoading = true;
  String _filtroSeleccionado = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarBitacora();
  }

  Future<void> _cargarBitacora() async {
    setState(() => isLoading = true);
    try {
      final data = await BitacoraService.obtenerMovimientos();
      if (!mounted) return;
      setState(() {
        movimientos = data;
        movimientosFiltrados = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la bitácora: $e', style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _filtrarMovimientos(String filtro) {
    setState(() {
      _filtroSeleccionado = filtro;
      if (filtro == 'Todos') {
        movimientosFiltrados = movimientos;
      } else if (filtro == 'Creaciones') {
        movimientosFiltrados = movimientos.where((m) => m.accion.toUpperCase() == 'INSERT').toList();
      } else if (filtro == 'Modificaciones') {
        movimientosFiltrados = movimientos.where((m) => m.accion.toUpperCase() == 'UPDATE').toList();
      } else if (filtro == 'Estados') {
        movimientosFiltrados = movimientos.where((m) => ['SUSPENDIDO', 'REACTIVADO', 'DELETE'].contains(m.accion.toUpperCase())).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final int total = movimientos.length;
    final int creaciones = movimientos.where((m) => m.accion.toUpperCase() == 'INSERT').length;
    final int modificaciones = movimientos.where((m) => m.accion.toUpperCase() == 'UPDATE').length;
    final int estados = movimientos.where((m) => ['SUSPENDIDO', 'REACTIVADO', 'DELETE'].contains(m.accion.toUpperCase())).length;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Bitácora de Movimientos', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1E1E24),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sincronizar',
            onPressed: _cargarBitacora,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.amber))
          : RefreshIndicator(
              onRefresh: _cargarBitacora,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con botón sincronizar
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial de cambios y auditoría general del sistema',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            foregroundColor: Colors.black,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.sync, size: 18),
                          label: const Text('Sincronizar', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: _cargarBitacora,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Filtros y conteo
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _construirFiltroChip('Todos', total),
                              const SizedBox(width: 8),
                              _construirFiltroChip('Creaciones', creaciones),
                              const SizedBox(width: 8),
                              _construirFiltroChip('Modificaciones', modificaciones),
                              const SizedBox(width: 8),
                              _construirFiltroChip('Estados', estados),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Mostrando ${movimientosFiltrados.length} de $total',
                        style: const TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // Tabla de datos
                Expanded(
                  child: movimientosFiltrados.isEmpty
                      ? const Center(child: Text('No hay registros disponibles', style: TextStyle(color: Colors.grey)))
                      : SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
                              columns: const [
                                DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Detalles del movimiento', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Módulo', style: TextStyle(fontWeight: FontWeight.bold))),
                                DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold))),
                              ],
                              rows: movimientosFiltrados.map((mov) {
                                return DataRow(
                                  cells: [
                                    DataCell(Text('#${mov.id}', style: const TextStyle(fontWeight: FontWeight.bold))),
                                    DataCell(Text(mov.fechaFormateada)),
                                    DataCell(_construirBadgeAccion(mov.accion)),
                                    DataCell(
                                      ConstrainedBox(
                                        constraints: const BoxConstraints(maxWidth: 350),
                                        child: Text(
                                          mov.detalles,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ),
                                    DataCell(_construirBadgeModulo(mov.modulo)),
                                    DataCell(Text(mov.usuarioEmail)),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _construirFiltroChip(String label, int cantidad) {
    final bool seleccionado = _filtroSeleccionado == label;
    return ChoiceChip(
      label: Text('$label $cantidad'),
      selected: seleccionado,
      selectedColor: const Color(0xFF1E1E24),
      backgroundColor: Colors.grey.shade100,
      labelStyle: TextStyle(
        color: seleccionado ? Colors.white : Colors.grey.shade800,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
      onSelected: (_) => _filtrarMovimientos(label),
    );
  }

  Widget _construirBadgeAccion(String accion) {
    Color colorFondo;
    Color colorTexto;

    switch (accion.toUpperCase()) {
      case 'INSERT':
        colorFondo = Colors.green.shade100;
        colorTexto = Colors.green.shade800;
        break;
      case 'UPDATE':
        colorFondo = Colors.amber.shade100;
        colorTexto = Colors.amber.shade900;
        break;
      case 'SUSPENDIDO':
      case 'DELETE':
        colorFondo = Colors.red.shade100;
        colorTexto = Colors.red.shade800;
        break;
      case 'REACTIVADO':
        colorFondo = Colors.blue.shade100;
        colorTexto = Colors.blue.shade800;
        break;
      default:
        colorFondo = Colors.grey.shade200;
        colorTexto = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        accion.toUpperCase(),
        style: TextStyle(color: colorTexto, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _construirBadgeModulo(String modulo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        modulo,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 11),
      ),
    );
  }
}