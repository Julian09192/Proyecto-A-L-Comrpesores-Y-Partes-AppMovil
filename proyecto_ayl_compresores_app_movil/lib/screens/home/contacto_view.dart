import 'package:flutter/material.dart';

class ContactoView extends StatelessWidget {
  const ContactoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Contactos',
          style: TextStyle(
            color: Color(0xFF1E242B),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera informativa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2537),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asesoría y Canales Directos',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Comunícate con nuestro equipo técnico en A&L Compresores y Partes para resolver cualquier solicitud.',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Opciones de Comunicación',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F2537),
              ),
            ),
            const SizedBox(height: 12),

            // Tarjetas de contacto dinámicas
            _construirItemContacto(
              titulo: 'Soporte vía WhatsApp',
              detalle: 'Atención rápida para repuestos',
              icono: Icons.chat_bubble_rounded,
              color: const Color(0xFF10B981),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _construirItemContacto(
              titulo: 'Llamada Comercial',
              detalle: '+57 (1) 000-0000',
              icono: Icons.phone_forwarded_rounded,
              color: const Color(0xFFFDB913),
              onTap: () {},
            ),
            const SizedBox(height: 10),
            _construirItemContacto(
              titulo: 'Correo Electrónico de Soporte',
              detalle: 'soporte@alcompresores.com',
              icono: Icons.mail_outline_rounded,
              color: const Color(0xFF6366F1),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirItemContacto({
    required String titulo,
    required String detalle,
    required IconData icono,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icono, color: color, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: Color(0xFF0F2537),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        detalle,
                        style: const TextStyle(
                          color: Color(0xFF7A837E),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Color(0xFF7A837E),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}