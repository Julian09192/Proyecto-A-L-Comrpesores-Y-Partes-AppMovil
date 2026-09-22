import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/reportes/reporte_model.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/reporte/reporte_service.dart';
import '../../widgets/empleado/navbar_empleado.dart';

// 🚀 Paleta corporativa A&L: Negro, Blanco y Amarillo #FDB913
const Color empleadoAmarillo = Color(0xFFFDB913);
const Color empleadoRojo = Color(0xFFFDB913);
const Color empleadoFondo = Color(0xFFF7F8FA);
const Color empleadoTexto = Color(0xFF0F2537);
const Color empleadoTextoSecundario = Color(0xFF7A837E);

class EmpleadoReportesView extends StatefulWidget {
  const EmpleadoReportesView({super.key});

  @override
  State<EmpleadoReportesView> createState() => _EmpleadoReportesViewState();
}

class _EmpleadoReportesViewState extends State<EmpleadoReportesView> {
  ReporteInventarioResponse? _reporte;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final data = await ReporteService.obtenerInventario(
        tipoReporte: 'stock',
        categoria: 'todas',
        proveedor: 'todos',
      );
      if (mounted) {
        setState(() {
          _reporte = data;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resumen = _reporte?.resumen;
    final categorias = _reporte?.categorias ?? [];

    return Scaffold(
      backgroundColor: empleadoFondo,
      drawer: const NavbarEmpleado(activeTitle: 'Reportes'),
      appBar: AppBar(
        title: const Text(
          'Reportes e Informes',
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
            icon: const Icon(Icons.sync_rounded, color: empleadoTexto),
            tooltip: 'Sincronizar reportes',
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
            if (_loading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(
                    color: empleadoAmarillo,
                    strokeWidth: 2.5,
                  ),
                ),
              )
            else ...[
              // Tarjetas de Métricas Superiores
              Row(
                children: [
                  Expanded(
                    child: _construirMetricaCard(
                      'PRODUCTOS',
                      '${resumen?.totalProductos ?? 0}',
                      Icons.inventory_2_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _construirMetricaCard(
                      'STOCK TOTAL',
                      '${resumen?.stockTotal ?? 0}',
                      Icons.layers_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _construirMetricaCard(
                      'VALOR TOTAL',
                      '\$${(resumen?.valorTotal ?? 0).toStringAsFixed(0)}',
                      Icons.payments_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Contenedor principal de Stock por Categoría
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
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
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock por Categoría',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          color: empleadoTexto,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (categorias.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(
                            child: Text(
                              'No hay datos de categorías disponibles',
                              style: TextStyle(
                                color: empleadoTextoSecundario,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: categorias.length,
                          separatorBuilder: (_, _) =>
                              Divider(height: 1, color: Colors.grey.shade100),
                          itemBuilder: (context, index) {
                            final cat = categorias[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    cat.categoria,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      color: empleadoTexto,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0F2537).withValues(
                                        alpha: 0.08,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${cat.stockTotal} unds',
                                      style: const TextStyle(
                                        color: empleadoTexto,
                                        fontWeight: FontWeight.w900,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _construirMetricaCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    color: empleadoTextoSecundario,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Icon(icon, color: const Color(0xFF0F2537), size: 16),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: empleadoTexto,
              ),
            ),
          ),
        ],
      ),
    );
  }
}