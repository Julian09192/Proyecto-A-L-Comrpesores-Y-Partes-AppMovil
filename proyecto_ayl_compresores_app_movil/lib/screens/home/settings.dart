import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- IMPORTAMOS LOS NUEVOS ARCHIVOS SEPARADOS ---
import 'nosotros_screen.dart';
import 'contacto_screen.dart';
import 'faq_screen.dart';
import 'legal_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _abrirWhatsAppSoporte() async {
    const String telefono = '573114405432';
    final String texto = Uri.encodeComponent(
      'Hola A&L Compresores, necesito solicitar asistencia técnica para mi equipo.',
    );

    final Uri urlApp = Uri.parse('whatsapp://send?phone=$telefono&text=$texto');
    final Uri urlWeb = Uri.parse('https://wa.me/$telefono?text=$texto');

    if (await canLaunchUrl(urlApp)) {
      await launchUrl(urlApp);
    } else {
      await launchUrl(urlWeb, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.only(
        top: topPadding + 85,
        bottom: bottomPadding + 90, 
        left: 16,
        right: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _construirTarjetaSoporteTecnico(),
          const SizedBox(height: 24),

          _construirEncabezadoSeccion('EMPRESA'),
          const SizedBox(height: 10),
          _construirBotonAjuste(
            icono: Icons.apartment_rounded,
            colorFondoIcono: const Color(0xFFE8EAF6),
            colorIcono: const Color(0xFF3F51B5),
            titulo: 'Nosotros',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NosotrosScreen())),
          ),
          const SizedBox(height: 10),
          _construirBotonAjuste(
            icono: Icons.phone_outlined,
            colorFondoIcono: const Color(0xFFEDE7F6),
            colorIcono: const Color(0xFF5E35B1),
            titulo: 'Contacto',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactoScreen())),
          ),
          const SizedBox(height: 10),
          _construirBotonAjuste(
            icono: Icons.help_outline_rounded,
            colorFondoIcono: const Color(0xFFE0F2F1),
            colorIcono: const Color(0xFF00796B),
            titulo: 'Preguntas Frecuentes',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FaqScreen())),
          ),
          const SizedBox(height: 24),

          _construirEncabezadoSeccion('LEGAL'),
          const SizedBox(height: 10),
          _construirBotonAjuste(
            icono: Icons.gavel_rounded,
            colorFondoIcono: const Color(0xFFEFEBE9),
            colorIcono: const Color(0xFF5D4037),
            titulo: 'Términos y Condiciones',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(
              titulo: 'Términos y Condiciones',
              contenido: '1. Aceptación de los Términos...\nAl acceder y utilizar la aplicación de A&L Compresores, usted acepta estar sujeto a estos términos y condiciones.\n\n2. Uso de la Aplicación...\nUsted se compromete a utilizar la aplicación únicamente para fines legales y de acuerdo con estos términos.\n\n3. Precios y Cotizaciones...\nLos precios mostrados están sujetos a cambios sin previo aviso. Toda cotización debe ser confirmada por un asesor.\n\n4. Propiedad Intelectual...\nTodo el contenido de esta aplicación es propiedad de A&L Compresores y Partes.',
            ))),
          ),
          const SizedBox(height: 10),
          _construirBotonAjuste(
            icono: Icons.shield_outlined,
            colorFondoIcono: const Color(0xFFECEFF1),
            colorIcono: const Color(0xFF455A64),
            titulo: 'Aviso de Privacidad',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LegalScreen(
              titulo: 'Aviso de Privacidad',
              contenido: 'En A&L Compresores y Partes valoramos su privacidad.\n\n1. Recopilación de Datos...\nRecopilamos información personal como nombre, correo electrónico y teléfono únicamente para la gestión de sus solicitudes y pedidos.\n\n2. Uso de la Información...\nSu información no será compartida con terceros sin su consentimiento expreso, excepto cuando sea requerido por ley.\n\n3. Seguridad...\nImplementamos medidas de seguridad para proteger su información contra acceso no autorizado.\n\nPara consultas sobre sus datos, contáctenos en contacto@aylcompresores.com.',
            ))),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // --- TARJETA SOPORTE TÉCNICO ---
  Widget _construirTarjetaSoporteTecnico() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDE8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 90,
                height: 90,
                color: const Color(0xFFE8E0D5),
              ),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.support_agent_rounded,
                  color: Color(0xFFFDB913),
                  size: 26,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Soporte Técnico',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E242B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 220,
                    child: Text(
                      '¿Necesita ayuda con su equipo? Nuestro equipo está listo.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black.withValues(alpha: 0.65),
                        height: 1.35,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDB913),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _abrirWhatsAppSoporte,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.person_outline_rounded, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'SOLICITAR ASISTENCIA',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
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

  Widget _construirEncabezadoSeccion(String titulo) {
    return Text(
      titulo,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: Color(0xFFD69420),
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _construirBotonAjuste({
    required IconData icono,
    required Color colorFondoIcono,
    required Color colorIcono,
    required String titulo,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: colorFondoIcono,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icono, color: colorIcono, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E242B),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: Color(0xFF7A837E),
            ),
          ],
        ),
      ),
    );
  }
}