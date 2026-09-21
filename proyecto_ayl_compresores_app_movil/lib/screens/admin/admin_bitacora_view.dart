import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/bitacora/bitacora_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/bitacora/bitacora_service.dart';
import '../../widgets/admin/navbar_admin.dart';

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
      backgroundColor: const Color(0xFFF7F8FA), // Fondo unificado con el resto de la app
      drawer: const NavbarAdmin(activeTitle: 'Bitácora'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
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
        iconTheme: const IconThemeData(color: Color(0xFF1E242B)),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF1E242B), size: 22),
            tooltip: 'Sincronizar',
            onPressed: _cargarBitacora,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFDB913)))
          : RefreshIndicator(
              onRefresh: _cargarBitacora,
              color: const Color(0xFFFDB913),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cabecera descriptiva estilo app
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bitácora de Movimientos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F2537),
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Historial de cambios y auditoría general del sistema',
                          style: TextStyle(color: Color(0xFF7A837E), fontSize: 12, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Filtros y conteo moderno
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
                    ),
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
                          '${movimientosFiltrados.length} de $total',
                          style: const TextStyle(color: Color(0xFF7A837E), fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Tabla de datos rediseñada
                  Expanded(
                    child: movimientosFiltrados.isEmpty
                        ? const Center(child: Text('No hay registros disponibles', style: TextStyle(color: Color(0xFF7A837E))))
                        : SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: WidgetStateProperty.all(const Color(0xFFF7F8FA)),
                                columns: const [
                                  DataColumn(label: Text('ID', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                  DataColumn(label: Text('Fecha y Hora', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                  DataColumn(label: Text('Acción', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                  DataColumn(label: Text('Detalles del movimiento', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                  DataColumn(label: Text('Módulo', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                  DataColumn(label: Text('Usuario', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF0F2537)))),
                                ],
                                rows: movimientosFiltrados.map((mov) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text('#${mov.id}', style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF222222)))),
                                      DataCell(Text(mov.fechaFormateada, style: const TextStyle(color: Color(0xFF555555), fontSize: 12))),
                                      DataCell(_construirBadgeAccion(mov.accion)),
                                      DataCell(
                                        ConstrainedBox(
                                          constraints: const BoxConstraints(maxWidth: 320),
                                          child: Text(
                                            mov.detalles,
                                            style: const TextStyle(color: Color(0xFF333333), fontSize: 12),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(_construirBadgeModulo(mov.modulo)),
                                      DataCell(Text(mov.usuarioEmail, style: const TextStyle(color: Color(0xFF555555), fontSize: 12))),
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
    return InkWell(
      onTap: () => _filtrarMovimientos(label),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: seleccionado ? const Color(0xFF222222) : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: seleccionado ? const Color(0xFF222222) : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child: Text(
          '$label ($cantidad)',
          style: TextStyle(
            color: seleccionado ? const Color(0xFFFDB913) : const Color(0xFF555555),
            fontWeight: seleccionado ? FontWeight.w800 : FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _construirBadgeAccion(String accion) {
    Color colorFondo;
    Color colorTexto;

    switch (accion.toUpperCase()) {
      case 'INSERT':
        colorFondo = Colors.green.shade50;
        colorTexto = Colors.green.shade700;
        break;
      case 'UPDATE':
        colorFondo = const Color(0xFFFFF7DB);
        colorTexto = Colors.amber.shade900;
        break;
      case 'SUSPENDIDO':
      case 'DELETE':
        colorFondo = Colors.red.shade50;
        colorTexto = Colors.red.shade700;
        break;
      case 'REACTIVADO':
        colorFondo = Colors.blue.shade50;
        colorTexto = Colors.blue.shade700;
        break;
      default:
        colorFondo = Colors.grey.shade100;
        colorTexto = Colors.grey.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        accion.toUpperCase(),
        style: TextStyle(color: colorTexto, fontWeight: FontWeight.w800, fontSize: 10.5),
      ),
    );
  }

  Widget _construirBadgeModulo(String modulo) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        modulo,
        style: const TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w700, fontSize: 11),
      ),
    );
  }
}