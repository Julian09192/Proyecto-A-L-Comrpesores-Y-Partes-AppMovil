import 'package:flutter/material.dart';
import 'contacto_screen.dart'; // Asegúrate de tener este archivo para el botón CTA

class NosotrosScreen extends StatelessWidget {
  const NosotrosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nosotros',
          style: TextStyle(color: Color(0xFF1E242B), fontWeight: FontWeight.w900, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E242B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           

            // 2. INFO SECCIÓN (Quiénes Somos & Misión)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: _construirInfoSeccion(),
            ),

            // 3. WHY CHOOSE US (Por qué elegirnos)
            Container(
              width: double.infinity,
              color: const Color(0xFFF7F8FA),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: _construirWhyChooseUs(),
            ),

            // 4. CAROUSEL (Galería de la empresa)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: _construirCarousel(),
            ),

            // 5. CTA (Call to Action)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
              child: _construirCTA(context),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // 1. HERO SECTION
  // =========================================

  // ==========================================
  // 2. INFO SECCIÓN
  // ==========================================
  Widget _construirInfoSeccion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nuestra Historia', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E242B))),
        const SizedBox(height: 16),
        Text(
          'Somos una empresa especializada en proveer soluciones integrales para la industria. Con años de experiencia en el mercado, nos dedicamos a la comercialización de repuestos, consumibles y servicio técnico para compresores de aire y maquinaria pesada.\n\nTrabajamos incansablemente para garantizar que las operaciones de nuestros clientes nunca se detengan.',
          style: TextStyle(fontSize: 14.5, color: Colors.black.withValues(alpha: 0.65), height: 1.6),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE0E0E0)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: Color(0xFFFDB913)),
                  SizedBox(width: 8),
                  Text('Nuestra Misión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF1E242B))),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Proveer repuestos y servicios técnicos de la más alta calidad, optimizando el rendimiento de la maquinaria industrial de nuestros clientes a nivel nacional.',
                style: TextStyle(fontSize: 13.5, color: Colors.black.withValues(alpha: 0.6), height: 1.5),
              ),
            ],
          ),
        )
      ],
    );
  }

  // ==========================================
  // 3. WHY CHOOSE US
  // ==========================================
  Widget _construirWhyChooseUs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('¿Por qué elegirnos?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E242B))),
        const SizedBox(height: 24),
        _itemPorQueElegirnos(Icons.verified_rounded, 'Calidad Original', 'Distribuimos marcas líderes y certificadas para asegurar el mejor rendimiento.'),
        const SizedBox(height: 16),
        _itemPorQueElegirnos(Icons.support_agent_rounded, 'Asesoría Técnica', 'Nuestro equipo experto te ayuda a encontrar la pieza exacta que necesitas.'),
        const SizedBox(height: 16),
        _itemPorQueElegirnos(Icons.local_shipping_rounded, 'Envíos Rápidos', 'Logística optimizada para despachos ágiles a cualquier parte del país.'),
      ],
    );
  }

  Widget _itemPorQueElegirnos(IconData icono, String titulo, String descripcion) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE0E0E0))),
          child: Icon(icono, color: const Color(0xFFFDB913), size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: Color(0xFF1E242B))),
              const SizedBox(height: 4),
              Text(descripcion, style: TextStyle(fontSize: 13.5, color: Colors.black.withValues(alpha: 0.6), height: 1.4)),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 4. CAROUSEL
  // ==========================================
  Widget _construirCarousel() {
    // Lista simulada para el carrusel (puedes reemplazar con imágenes de red reales)
    final items = [
      {'icon': Icons.precision_manufacturing_rounded, 'title': 'Taller Principal'},
      {'icon': Icons.inventory_2_rounded, 'title': 'Almacén de Repuestos'},
      {'icon': Icons.engineering_rounded, 'title': 'Equipo Técnico'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Nuestras Instalaciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF1E242B))),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 180,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              return Container(
                width: 260,
                decoration: BoxDecoration(
                  color: const Color(0xFF222222),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Fondo simulando imagen oscura
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(items[index]['icon'] as IconData, size: 120, color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    Center(
                      child: Icon(items[index]['icon'] as IconData, size: 50, color: const Color(0xFFFDB913)),
                    ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: Text(
                        items[index]['title'] as String,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // 5. CTA (Call To Action)
  // ==========================================
  Widget _construirCTA(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: const Color(0xFFFDB913),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFDB913).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '¿Listo para optimizar tu industria?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF141414), height: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Contáctanos hoy mismo y recibe atención personalizada.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: const Color(0xFF141414).withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF141414),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ContactoScreen()),
              );
            },
            child: const Text('CONTACTAR AHORA', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}