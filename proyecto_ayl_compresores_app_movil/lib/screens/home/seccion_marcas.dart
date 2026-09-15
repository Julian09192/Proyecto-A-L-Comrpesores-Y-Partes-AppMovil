import 'package:flutter/material.dart';

class SeccionMarcas extends StatelessWidget {
  const SeccionMarcas({super.key});

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
              Text(
                'Ver todas',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: marcas.map((marca) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.black.withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        marca['icono'] as IconData,
                        size: 18,
                        color: const Color(0xFF5E6061),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        marca['nombre'] as String,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF222222),
                        ),
                      ),
                    ],
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