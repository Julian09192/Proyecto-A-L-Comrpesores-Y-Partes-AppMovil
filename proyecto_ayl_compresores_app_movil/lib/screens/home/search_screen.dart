import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/product_card.dart';
import '../productos/detail_product.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ProductoService _productoService = ProductoService();

  Future<List<ProductoModel>>? _futureBusqueda;
  late Future<List<ProductoModel>> _futureRecomendados;

  final List<String> _busquedasRecientes = [
    'Filtro separador',
    'Aceite 20w50',
    'Pistón',
    'Donaldson',
    'Válvula de alivio',
  ];

  @override
  void initState() {
    super.initState();
    _futureRecomendados = _productoService.filterByParams();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _ejecutarBusqueda(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _futureBusqueda = null;
      });
      return;
    }

    if (!_busquedasRecientes.contains(query.trim())) {
      setState(() {
        _busquedasRecientes.insert(0, query.trim());
      });
    }

    setState(() {
      _futureBusqueda = _productoService.filterByParams(
        searchQuery: query.trim(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Buscar Repuestos',
          style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      body: Stack(
        children: [
          // 1. Cuerpo principal (Sugerencias o Resultados) con espacio abajo para que no lo tape la barra
          Padding(
            padding: const EdgeInsets.only(bottom: 85),
            child: _futureBusqueda != null
                ? _construirResultadosBusqueda()
                : _construirPanelSugerenciasErgonomicas(),
          ),

          // 2. Barra de búsqueda flotante en la parte INFERIOR (Ergonómica para el pulgar)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 15,
                    offset: const Offset(0, -4),
                  ),
                ],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F8FA),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.search, color: Color(0xFF7A837E), size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onSubmitted: _ejecutarBusqueda,
                              onChanged: (text) {
                                if (text.isEmpty) {
                                  setState(() {
                                    _futureBusqueda = null;
                                  });
                                }
                              },
                              textInputAction: TextInputAction.search,
                              decoration: InputDecoration(
                                hintText: '¿Qué estás buscando?',
                                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.grey, size: 18),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _futureBusqueda = null;
                                });
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de enviar / buscar rápido
                  GestureDetector(
                    onTap: () => _ejecutarBusqueda(_searchController.text),
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF222222),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Color(0xFFFDB913),
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirPanelSugerenciasErgonomicas() {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      children: [
        if (_busquedasRecientes.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Buscaste recientemente',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F2537),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _busquedasRecientes.clear();
                  });
                },
                child: const Text(
                  'Limpiar',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _busquedasRecientes.map((termino) {
              return InkWell(
                onTap: () {
                  _searchController.text = termino;
                  _ejecutarBusqueda(termino);
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.06)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    termino,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
        ],

        const Text(
          'Vistos recientemente',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F2537),
          ),
        ),
        const SizedBox(height: 14),

        FutureBuilder<List<ProductoModel>>(
          future: _futureRecomendados,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 140,
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFFFDB913)),
                ),
              );
            }

            final productos = snapshot.data ?? [];
            if (productos.isEmpty) {
              return const SizedBox.shrink();
            }

            return SizedBox(
              height: 165,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: productos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final producto = productos[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetalleProductoPage(
                            id: producto.id.toString(),
                            nombre: producto.nombre,
                            marca: producto.marca,
                            precio: '\$${producto.precio.toStringAsFixed(0)}',
                            imagenUrl: producto.imagenUrl ?? '',
                            descripcion: producto.caracteristicas.isNotEmpty
                                ? producto.caracteristicas
                                : 'Sin descripción técnica disponible.',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black.withValues(alpha: 0.04)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: 75,
                            width: 75,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: (producto.imagenUrl != null &&
                                    producto.imagenUrl!.trim().isNotEmpty)
                                ? Image.network(
                                    producto.imagenUrl!.trim(),
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.inventory_2_outlined,
                                      color: Colors.grey,
                                      size: 30,
                                    ),
                                  )
                                : const Icon(
                                    Icons.inventory_2_outlined,
                                    color: Colors.grey,
                                    size: 30,
                                  ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            producto.nombre,
                            maxLines: 2,
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF333333),
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _construirResultadosBusqueda() {
    return FutureBuilder<List<ProductoModel>>(
      future: _futureBusqueda,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFDB913)),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error al buscar: ${snapshot.error}',
              style: const TextStyle(color: Colors.grey),
            ),
          );
        }

        final productos = snapshot.data ?? [];
        if (productos.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded, size: 50, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text(
                  'No encontramos repuestos con ese término.',
                  style: TextStyle(color: Colors.grey, fontSize: 13.5, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: productos.length,
          itemBuilder: (context, index) {
            final producto = productos[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: ProductoCard(
                producto: producto,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetalleProductoPage(
                        id: producto.id.toString(),
                        nombre: producto.nombre,
                        marca: producto.marca,
                        precio: '\$${producto.precio.toStringAsFixed(0)}',
                        imagenUrl: producto.imagenUrl ?? '',
                        descripcion: producto.caracteristicas.isNotEmpty
                            ? producto.caracteristicas
                            : 'Sin descripción técnica disponible.',
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}