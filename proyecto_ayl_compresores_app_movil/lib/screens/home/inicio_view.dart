import 'package:flutter/material.dart';

class InicioView extends StatelessWidget {
  const InicioView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _construirBannerPrincipal(),
            const SizedBox(height: 20),

            _construirTituloSeccion('¿Por qué elegirnos?'),
            _construirBeneficios(),

            const SizedBox(height: 20),

            _construirTituloSeccion('Productos Destacados'),
            _construirProductosDestacados(),

            const SizedBox(height: 30),
          ],
        ), // <-- Cierra el Column
      ), // <-- Cierra el SingleChildScrollView
    ); // <-- Cierra el SafeArea (¡Este era el que faltaba!)
  }

  // --- MÉTODOS PARA CONSTRUIR CADA SECCIÓN --- //

  // 1. El banner grande (Ahora con imagen de fondo y gradiente oscuro)
  Widget _construirBannerPrincipal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 40,
      ), // Más alto
      decoration: const BoxDecoration(
        // Aquí puedes cambiar este link por el de la imagen de tu tractor en la web
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1592978868661-09eb010e9474?q=80&w=1000&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Un filtro oscuro para que las letras blancas se lean perfecto
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Repuestos y Consumibles\npara Maquinaria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900, // Letra más gruesa
                height: 1.2, // Interlineado
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Filtros, aceites y separadores con la máxima protección para tu operación industrial.',
              style: TextStyle(color: Colors.white70, fontSize: 15),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'EXPLORAR CATÁLOGO',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Un pequeño título reutilizable para las secciones
  Widget _construirTituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 3. Fila horizontal de beneficios (Envío rápido, Garantía, etc.)
  Widget _construirBeneficios() {
    // Un scroll horizontal para no amontonar las tarjetas
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _tarjetaBeneficio(Icons.build, 'Repuestos Originales'),
          _tarjetaBeneficio(Icons.local_shipping, 'Envío Rápido'),
          _tarjetaBeneficio(Icons.support_agent, 'Soporte Técnico'),
        ],
      ),
    );
  }

  // Diseño individual de la tarjeta de beneficio
  Widget _tarjetaBeneficio(IconData icono, String texto) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10), // Bordes redondeados
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icono, color: Colors.amber, size: 40),
          const SizedBox(height: 10),
          Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // 4. Lista horizontal de productos para el inicio
  Widget _construirProductosDestacados() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _tarjetaProducto('Filtro Separador FS-19732', 'Aceite', '\$185.000'),
          _tarjetaProducto('Aceite 20w50', 'Lubricante', '\$250.000'),
          _tarjetaProducto('Filtro Donaldson FS200', 'Repuesto', '\$185.000'),
        ],
      ),
    );
  }

  // 2. Tarjetas de producto más elegantes (Con sombras e imágenes)
  Widget _tarjetaProducto(String nombre, String categoria, String precio) {
    return Container(
      width: 180, // Un poco más ajustado
      margin: const EdgeInsets.only(
        right: 15,
        bottom: 10,
      ), // Margen para la sombra
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // Bordes más suaves
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4), // Sombra hacia abajo
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Área de la imagen del repuesto/filtro
          ClipRRect(
            // Recorta la imagen para que respete los bordes redondeados
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: Colors.grey.shade100,
              // Aquí pondremos luego la imagen de tu base de datos Supabase
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          // Área de texto
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria,
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 2, // Si el nombre es largo, usa máximo 2 líneas
                  overflow: TextOverflow.ellipsis, // Pone "..." si no cabe
                ),
                const SizedBox(height: 8),
                Text(
                  precio,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Ver detalles',
                      style: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
