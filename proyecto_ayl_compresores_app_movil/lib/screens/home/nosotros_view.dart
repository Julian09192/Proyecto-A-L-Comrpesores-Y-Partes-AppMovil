import 'package:flutter/material.dart';

class NosotrosView extends StatelessWidget {
  final VoidCallback? onExplorarCatalogo;

  const NosotrosView({super.key, this.onExplorarCatalogo});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera Hero
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E1E24), Color(0xFF2C2D35)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'A&L',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Compresores y Partes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Potencia y Confiabilidad para la Industria',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Somos especialistas en distribución, mantenimiento y suministro de repuestos de alta gama para sistemas de aire comprimido, lubricantes sintéticos y filtración pesada.',
                    style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Misión y Visión
            const Text(
              'Nuestra Empresa',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _tarjetaInfo(
              icon: Icons.flag_rounded,
              titulo: 'Nuestra Misión',
              descripcion:
                  'Asegurar la continuidad operativa de las empresas colombianas suministrando componentes, lubricantes y consumibles de máxima calidad, con respaldo técnico inmediato y asesoría experta.',
            ),
            const SizedBox(height: 12),
            _tarjetaInfo(
              icon: Icons.visibility_rounded,
              titulo: 'Nuestra Visión',
              descripcion:
                  'Consolidarnos como el proveedor integral referente a nivel nacional en repuestos y mantenimiento especializado para compresores industriales de tornillo y pistón.',
            ),
            const SizedBox(height: 24),

            // Pilares de Valor
            const Text(
              '¿Por qué confiar en A&L?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _pilarItem(
              icon: Icons.verified_rounded,
              color: Colors.amber,
              titulo: 'Calidad Certificada',
              subtitulo: 'Repuestos y aceites de especificación OEM de alto rendimiento.',
            ),
            _pilarItem(
              icon: Icons.speed_rounded,
              color: Colors.blue,
              titulo: 'Despachos Ágiles',
              subtitulo: 'Entregas oportunas para minimizar paradas imprevistas de planta.',
            ),
            _pilarItem(
              icon: Icons.engineering_rounded,
              color: Colors.green,
              titulo: 'Asesoría de Ingenieros',
              subtitulo: 'Acompañamiento en selección de filtros y aceites según tu maquinaria.',
            ),
            const SizedBox(height: 24),

            // Llamado a la acción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.amber.shade200, width: 1.5),
              ),
              child: Column(
                children: [
                  const Text(
                    '¿Listo para equipar tu planta?',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Explora nuestro catálogo en línea o solicita cotización de referencias especiales.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onExplorarCatalogo,
                      child: const Text(
                        'EXPLORAR CATÁLOGO',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _tarjetaInfo({
    required IconData icon,
    required String titulo,
    required String descripcion,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.amber.shade100,
            child: Icon(icon, color: Colors.amber.shade900, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pilarItem({
    required IconData icon,
    required Color color,
    required String titulo,
    required String subtitulo,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  subtitulo,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
