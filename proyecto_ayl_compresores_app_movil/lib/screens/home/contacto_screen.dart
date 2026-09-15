import 'package:flutter/material.dart';

class ContactoScreen extends StatelessWidget {
  const ContactoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Contacto y Soporte',
          style: TextStyle(
            color: Color(0xFF1E242B),
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E242B)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Bienvenida / Cabecera
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F2537),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A&L Compresores y Partes',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Estamos listos para atender tus requerimientos industriales con soporte técnico especializado.',
                    style: TextStyle(
                      color: Color(0xFF9CA3AF),
                      fontSize: 12.5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Canales de Atención',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F2537),
              ),
            ),
            const SizedBox(height: 12),

            // Opciones de contacto interactivas
            _construirOpcionContacto(
              context,
              titulo: 'Línea Telefónica / WhatsApp',
              subtitulo: '+57 (1) 000-0000',
              icono: Icons.phone_rounded,
              color: const Color(0xFF10B981),
              onTap: () {
                // Acción para llamada o WhatsApp
              },
            ),
            const SizedBox(height: 10),
            _construirOpcionContacto(
              context,
              titulo: 'Correo Electrónico',
              subtitulo: 'contacto@alcompresores.com',
              icono: Icons.email_rounded,
              color: const Color(0xFFFDB913),
              onTap: () {
                // Acción para enviar correo
              },
            ),
            const SizedBox(height: 10),
            _construirOpcionContacto(
              context,
              titulo: 'Ubicación Principal',
              subtitulo: 'Bogotá D.C., Colombia',
              icono: Icons.location_on_rounded,
              color: const Color(0xFFF97316),
              onTap: () {
                // Acción para ver mapa
              },
            ),
            const SizedBox(height: 10),
            _construirOpcionContacto(
              context,
              titulo: 'Horario de Atención',
              subtitulo: 'Lunes a Viernes: 8:00 a.m. - 5:00 p.m.',
              icono: Icons.access_time_filled_rounded,
              color: const Color(0xFF6366F1),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _construirOpcionContacto(
    BuildContext context, {
    required String titulo,
    required String subtitulo,
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
                        subtitulo,
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
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7A837E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}