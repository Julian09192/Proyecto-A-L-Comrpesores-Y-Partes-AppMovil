import 'package:flutter/material.dart';
import '../../services/notificaciones/notificacion_service.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Definición de color rojo corporativo estándar
const Color empleadoRojo = Color(0xFFDC2626);
const Color empleadoFondo = Color(0xFFF7F8FA);
const Color empleadoTexto = Color(0xFF0F2537);
const Color empleadoTextoSecundario = Color(0xFF7A837E);

class EmpleadoNotificaciones extends StatefulWidget {
  const EmpleadoNotificaciones({super.key});

  @override
  State<EmpleadoNotificaciones> createState() => _EmpleadoNotificacionesState();
}

class _EmpleadoNotificacionesState extends State<EmpleadoNotificaciones> {
  final _service = NotificacionesService();
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;
  bool _soloNoLeidas = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await _service.obtenerNotificaciones();
      if (mounted) {
        setState(() {
          _items = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _marcarLeidas() async {
    await _service.marcarTodasComoLeidas();
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final visibles = _soloNoLeidas
        ? _items.where((n) => n['leido'] != true).toList()
        : _items;
    final noLeidas = _items.where((n) => n['leido'] != true).length;

    return Scaffold(
      backgroundColor: empleadoFondo,
      drawer: const NavbarEmpleado(activeTitle: 'Notificaciones'),
      appBar: AppBar(
        title: const Text(
          'Centro de Notificaciones',
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
            onPressed: noLeidas == 0 ? null : _marcarLeidas,
            icon: const Icon(Icons.done_all_rounded, color: empleadoRojo),
            tooltip: 'Marcar todas como leídas',
          ),
          IconButton(
            onPressed: _cargar,
            icon: const Icon(Icons.sync_rounded, color: empleadoRojo),
            tooltip: 'Sincronizar',
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
            // Filtros tipo ChoiceChip modernos
            Row(
              children: [
                _buildFiltro(
                  'Todas',
                  !_soloNoLeidas,
                  () => setState(() => _soloNoLeidas = false),
                ),
                const SizedBox(width: 10),
                _buildFiltro(
                  'No leídas ($noLeidas)',
                  _soloNoLeidas,
                  () => setState(() => _soloNoLeidas = true),
                ),
              ],
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
            else if (visibles.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Center(
                  child: Text(
                    'No hay notificaciones pendientes en el sistema.',
                    style: TextStyle(
                      color: empleadoTextoSecundario,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              )
            else
              ...visibles.map(_construirTarjetaNotificacion),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltro(String label, bool active, VoidCallback onTap) {
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onTap(),
      selectedColor: empleadoRojo,
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: active ? empleadoRojo : Colors.grey.shade300),
      ),
      labelStyle: TextStyle(
        color: active ? Colors.white : empleadoTexto,
        fontWeight: FontWeight.w700,
        fontSize: 12.5,
      ),
    );
  }

  Widget _construirTarjetaNotificacion(Map<String, dynamic> item) {
    final bool leida = item['leido'] == true;
    final String? imagenUrl =
        item['imagen_url']?.toString() ?? item['imagenUrl']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: leida ? Colors.white : empleadoRojo.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: leida
              ? Colors.grey.shade200
              : empleadoRojo.withValues(alpha: 0.3),
          width: leida ? 1.2 : 1.5,
        ),
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
            // Miniatura del producto en la notificación
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 55,
                height: 55,
                color: empleadoFondo,
                child: (imagenUrl != null && imagenUrl.trim().isNotEmpty)
                    ? Image.network(
                        imagenUrl.trim(),
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 22,
                        ),
                      )
                    : const Icon(
                        Icons.notifications_active_rounded,
                        color: empleadoRojo,
                        size: 24,
                      ),
              ),
            ),
            const SizedBox(width: 14),

            // Contenido de la notificación
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item['nombre_producto']?.toString() ??
                              'Alerta de Inventario',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                            color: empleadoTexto,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!leida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: empleadoRojo,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Stock registrado: ${item['stock_registrado'] ?? 0} unidades',
                    style: const TextStyle(
                      fontSize: 12,
                      color: empleadoTextoSecundario,
                      fontWeight: FontWeight.w600,
                    ),
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