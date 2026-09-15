import 'dart:ui';
import 'package:flutter/material.dart';

class DetalleProductoHeader extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onBackPress;

  const DetalleProductoHeader({
    super.key,
    required this.onBackPress,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            height: 60 + topPadding,
            padding: EdgeInsets.only(
              top: topPadding,
              left: 16,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.40),
                  width: 1.0,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Botón de retroceso
                IconButton(
                  splashRadius: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 40,
                    minHeight: 40,
                  ),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF2C3238),
                    size: 22,
                  ),
                  onPressed: onBackPress,
                ),
                const SizedBox(width: 4),
                // Logo de la empresa
                SizedBox(
                  height: 34,
                  child: Image.asset(
                    'assets/images/logo_ayl.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) =>
                        Image.network(
                      'https://res.cloudinary.com/duvoqozcl/image/upload/v1777394217/logo-ayl.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Text(
                          'A&L COMPRESORES',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2C3238),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}