import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../productos/detail_product.dart';

class InicioView extends StatefulWidget {
  final VoidCallback? onExplorarCatalogo;

  const InicioView({super.key, this.onExplorarCatalogo});

  @override
  State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureDestacados;

  @override
  void initState() {
    super.initState();
    _futureDestacados = _productoService.getAll(soloActivos: true);
  }

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

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Productos Destacados',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (widget.onExplorarCatalogo != null)
                    InkWell(
                      onTap: widget.onExplorarCatalogo,
                      child: const Row(
                        children: [
                          Text(
                            'Ver todos',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_ios, size: 12, color: Colors.amber),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _construirProductosDestacados(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // 1. Banner Principal
  Widget _construirBannerPrincipal() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 35),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1A1A20),
            Color(0xFF282830),
            Color(0xFF141416),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'A&L OFICIAL',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Soluciones Industriales',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Repuestos y Consumibles\npara Maquinaria',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Filtros, aceites y separadores con la máxima protección para tu operación industrial continua.',
              style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: widget.onExplorarCatalogo,
              icon: const Icon(Icons.storefront, size: 18),
              label: const Text(
                'EXPLORAR CATÁLOGO',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 2. Título de sección
  Widget _construirTituloSeccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Text(
        titulo,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  // 3. Fila de beneficios
  Widget _construirBeneficios() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _tarjetaBeneficio(Icons.build_circle_outlined, 'Repuestos Originales', 'OEM Certificados'),
          _tarjetaBeneficio(Icons.local_shipping_outlined, 'Envío Rápido', 'A todo el país'),
          _tarjetaBeneficio(Icons.support_agent_outlined, 'Soporte Técnico', 'Asesoría experta'),
          _tarjetaBeneficio(Icons.verified_outlined, 'Garantía Total', 'Respaldo de fábrica'),
        ],
      ),
    );
  }

  Widget _tarjetaBeneficio(IconData icono, String titulo, String subtitulo) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icono, color: Colors.amber, size: 36),
          const SizedBox(height: 8),
          Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // 4. Lista horizontal dinámica de productos destacados
  Widget _construirProductosDestacados() {
    return FutureBuilder<List<ProductoModel>>(
      future: _futureDestacados,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(color: Colors.amber),
            ),
          );
        }

        final productos = snapshot.data ?? [];

        if (productos.isEmpty) {
          // Fallback en caso de que no haya aún cargados
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Row(
              children: [
                _tarjetaProductoFallback('Filtro Separador FS-19732', 'FLEETGUARD', '\$185.000'),
                _tarjetaProductoFallback('Aceite Sintético Shroyer ISO 46', 'SHROYER', '\$890.000'),
                _tarjetaProductoFallback('Filtro Donaldson FS200', 'DONALDSON', '\$185.000'),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: productos.take(6).map((p) {
              return _tarjetaProductoReal(p);
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _tarjetaProductoReal(ProductoModel p) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: p.imagenUrl != null && p.imagenUrl!.isNotEmpty
                  ? Image.network(
                      p.imagenUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.inventory_2_outlined,
                        size: 50,
                        color: Colors.grey,
                      ),
                    )
                  : const Icon(
                      Icons.inventory_2_outlined,
                      size: 50,
                      color: Colors.grey,
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.marca.toUpperCase(),
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  p.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${p.precio.toStringAsFixed(0)} COP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoPage(
                            nombre: p.nombre,
                            marca: p.marca,
                            precio: '\$${p.precio.toStringAsFixed(0)}',
                            imagenUrl: p.imagenUrl ?? '',
                            descripcion: p.caracteristicas.isNotEmpty
                                ? p.caracteristicas
                                : 'Especificación técnica de alta resistencia industrial.',
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Ver detalles',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
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

  Widget _tarjetaProductoFallback(String nombre, String categoria, String precio) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Container(
              height: 130,
              width: double.infinity,
              color: Colors.grey.shade100,
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 50,
                color: Colors.grey,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  categoria,
                  style: TextStyle(
                    color: Colors.amber.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  precio,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onPressed: widget.onExplorarCatalogo,
                    child: const Text(
                      'Explorar catálogo',
                      style: TextStyle(color: Colors.black87, fontSize: 12),
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
