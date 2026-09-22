import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/bitacora/bitacora_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/bitacora/bitacora_service.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Paleta corporativa A&L: Negro, Blanco y Amarillo #FDB913
const Color empleadoAmarillo = Color(0xFFFDB913);
const Color empleadoRojo = Color(0xFFFDB913);

class EmpleadoBitacoraView extends StatefulWidget {
  const EmpleadoBitacoraView({super.key});

  @override
  State<EmpleadoBitacoraView> createState() => _EmpleadoBitacoraViewState();
}

class _EmpleadoBitacoraViewState extends State<EmpleadoBitacoraView> {
  List<MovimientoBitacora> _movimientos = [];
  bool _cargando = true;
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final data = await BitacoraService.obtenerMovimientos();
      if (!mounted) return;
      setState(() {
        _movimientos = data;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar la bitácora: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  List<MovimientoBitacora> get _visibles => _movimientos.where((item) {
    final accion = item.accion.toUpperCase();
    return _filtro == 'Todos' ||
        (_filtro == 'Creaciones' && accion == 'INSERT') ||
        (_filtro == 'Modificaciones' && accion == 'UPDATE') ||
        (_filtro == 'Estados' &&
            ['SUSPENDIDO', 'REACTIVADO', 'DELETE'].contains(accion));
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      drawer: const NavbarEmpleado(activeTitle: 'Bitácora'),
      appBar: AppBar(
        title: const Text(
          'Bitácora del Sistema',
          style: TextStyle(
            color: Color(0xFF0F2537),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F2537)),
        actions: [
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.sync_rounded, color: Color(0xFF0F2537)),
            tooltip: 'Sincronizar',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: empleadoAmarillo,
        onRefresh: _cargar,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Filtros tipo ChoiceChip modernos
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Creaciones', 'Modificaciones', 'Estados']
                    .map(
                      (filtro) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filtro),
                          selected: _filtro == filtro,
                          selectedColor: empleadoAmarillo,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(
                              color: _filtro == filtro
                                  ? empleadoAmarillo
                                  : Colors.grey.shade300,
                            ),
                          ),
                          labelStyle: const TextStyle(
                            color: Color(0xFF0F2537),
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                          ),
                          onSelected: (_) => setState(() => _filtro = filtro),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 20),
            if (_cargando)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: empleadoAmarillo,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else if (_visibles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No hay registros disponibles en la bitácora',
                    style: TextStyle(
                      color: Color(0xFF7A837E),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ..._visibles.map(_construirMovimiento),
          ],
        ),
      ),
    );
  }

  Widget _construirMovimiento(MovimientoBitacora movimiento) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: empleadoAmarillo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFF0F2537),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F2537).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          movimiento.accion.toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF0F2537),
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Text(
                        movimiento.fechaFormateada,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    movimiento.detalles,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF0F2537),
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          movimiento.usuarioEmail,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}