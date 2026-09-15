import 'dart:ui';
import 'package:flutter/material.dart';

class DetalleProductoBottomBar extends StatelessWidget {
  final VoidCallback onMenuPress;
  final VoidCallback onCartButtonPress;
  final int itemCount; // 🚀 Nuevo parámetro para recibir la cantidad de productos

  const DetalleProductoBottomBar({
    super.key,
    required this.onMenuPress,
    required this.onCartButtonPress,
    required this.itemCount,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 16,
      right: 16,
      bottom: bottomPadding > 0 ? bottomPadding + 6 : 18,
      child: Row(
        children: [
          // 🚀 Pastilla Izquierda: Agregar al Carrito
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(29),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(29),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(29),
                      color: const Color(0xFFFDB913).withValues(alpha: 0.85),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.50),
                        width: 1.2,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(29),
                        onTap: onMenuPress,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_shopping_cart_rounded, color: Colors.black87, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Agregar al carrito',
                              style: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w900,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 🚀 Pastilla Derecha: Botón de Carrito con Badge Dinámico
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(29),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.40),
                      width: 1.2,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF222222), size: 22),
                          onPressed: onCartButtonPress,
                        ),
                        if (itemCount > 0)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$itemCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}