import 'package:flutter/material.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {'pregunta': '¿Hacen envíos a nivel nacional?', 'respuesta': 'Sí, realizamos despachos a toda Colombia a través de transportadoras aliadas. El tiempo de entrega depende de tu ubicación y la disponibilidad del repuesto.'},
      {'pregunta': '¿Qué marcas de repuestos manejan?', 'respuesta': 'Trabajamos con repuestos de alta calidad de marcas como Donaldson, Fleetguard, Mobil, Ingersoll Rand y Atlas Copco, garantizando el rendimiento de tu maquinaria.'},
      {'pregunta': '¿Ofrecen servicio de instalación o soporte técnico?', 'respuesta': 'Sí, contamos con un equipo técnico especializado para brindarte asesoría en la compra y soporte técnico si tienes dudas con la compatibilidad.'},
      {'pregunta': '¿Cómo puedo solicitar una cotización formal?', 'respuesta': 'Puedes usar el botón de "WhatsApp" en la pantalla principal o contactarnos directamente en la sección de Contacto para enviarte una cotización formal a nombre de tu empresa.'},
      {'pregunta': '¿Qué métodos de pago aceptan?', 'respuesta': 'Aceptamos transferencias bancarias (Bancolombia, Davivienda), pagos por Nequi/Daviplata y pagos contra entrega en zonas seleccionadas de Bogotá.'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        elevation: 0,
        centerTitle: true,
        title: const Text('Preguntas Frecuentes', style: TextStyle(color: Color(0xFF1E242B), fontWeight: FontWeight.w900, fontSize: 16)),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E242B)), onPressed: () => Navigator.pop(context)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        itemCount: faqs.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 3))],
              ),
              child: Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: const Color(0xFFFDB913),
                  collapsedIconColor: Colors.grey,
                  tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  title: Text(
                    faqs[index]['pregunta']!,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1E242B)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                      child: Text(
                        faqs[index]['respuesta']!,
                        style: TextStyle(color: Colors.black.withValues(alpha: 0.6), height: 1.5, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}