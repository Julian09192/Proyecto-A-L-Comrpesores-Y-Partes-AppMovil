import 'package:flutter/material.dart';

class SeccionMarcas extends StatelessWidget {
  final Function(String) onMarcaSeleccionada;
  final VoidCallback onVerTodas;
  final String? marcaActiva; // Sirve para resaltar la marca si está filtrada

  const SeccionMarcas({
    super.key,
    required this.onMarcaSeleccionada,
    required this.onVerTodas,
    this.marcaActiva,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> marcas = [
      {'nombre': 'Donaldson', 'icono': Icons.filter_alt_outlined},
      {'nombre': 'Fleetguard', 'icono': Icons.shield_outlined},
      {'nombre': 'Mobil', 'icono': Icons.oil_barrel_outlined},
      {'nombre': 'Ingersoll Rand', 'icono': Icons.hardware_outlined},
      {'nombre': 'Sullair', 'icono': Icons.settings_input_component_outlined},
      {'nombre': 'Atlas Copco', 'icono': Icons.precision_manufacturing_outlined},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Marcas y Fabricantes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2537),
                ),
              ),
              InkWell(
                onTap: onVerTodas,
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  child: Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.amber.shade800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: marcas.map((marca) {
              final bool isSelected = marcaActiva == marca['nombre'];

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected 
                          ? const Color(0xFF222222) 
                          : Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: isSelected 
                        ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
                        : [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Material(
                    color: isSelected ? const Color(0xFF222222) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => onMarcaSeleccionada(marca['nombre']),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              marca['icono'] as IconData,
                              size: 18,
                              color: isSelected ? const Color(0xFFFDB913) : const Color(0xFF5E6061),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              marca['nombre'] as String,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                color: isSelected ? const Color(0xFFFDB913) : const Color(0xFF222222),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}