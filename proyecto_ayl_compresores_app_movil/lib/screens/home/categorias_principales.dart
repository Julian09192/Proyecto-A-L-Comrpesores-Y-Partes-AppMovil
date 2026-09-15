import 'package:flutter/material.dart';

class CategoriasPrincipales extends StatelessWidget {
  const CategoriasPrincipales({super.key, required this.onCategoriaTap});

  final ValueChanged<String> onCategoriaTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Categorías Principales',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F2537),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _tarjetaCategoria(
                icono: Icons.precision_manufacturing_outlined,
                nombre: 'Tornillo',
                isHighlighted: true,
                onTap: () => onCategoriaTap('Tornillo'),
              ),
              _tarjetaCategoria(
                icono: Icons.settings_outlined,
                nombre: 'Pistón',
                onTap: () => onCategoriaTap('Pistón'),
              ),
              _tarjetaCategoria(
                icono: Icons.oil_barrel_outlined,
                nombre: 'Aceite',
                onTap: () => onCategoriaTap('Aceite'),
              ),
              _tarjetaCategoria(
                icono: Icons.air_rounded,
                nombre: 'Libres de Aire',
                onTap: () => onCategoriaTap('Libres de Aire'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tarjetaCategoria({
    required IconData icono,
    required String nombre,
    bool isHighlighted = false,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isHighlighted
                  ? const Color(0xFFE5E9FE)
                  : const Color(0xFFEDEDED),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(icono, size: 26, color: const Color(0xFF333333)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2C3238),
            ),
          ),
        ],
      ),
    );
  }
}