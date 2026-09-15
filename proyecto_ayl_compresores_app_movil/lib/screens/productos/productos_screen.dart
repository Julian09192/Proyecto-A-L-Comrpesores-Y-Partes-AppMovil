import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../widgets/product_card.dart';
import '../home/search_screen.dart';
import 'detail_product.dart';
import '../home/main_navigation.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoriaInicial;
  final bool showBackButton;

  const ProductsScreen({
    super.key,
    this.categoriaInicial,
    this.showBackButton = false,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCategoryIndex = 0;
  final ProductoService _productoService = ProductoService();
  late Future<List<ProductoModel>> _futureProductos;

  // Lista base de todos los productos para extraer marcas y límites de precio
  List<ProductoModel> _todosLosProductos = [];
  List<String> _marcasDisponibles = [];

  // Filtros aplicados
  String? _marcaSeleccionada;
  RangeValues? _rangoPrecioSeleccionado;
  double _minPrecioGeneral = 0;
  double _maxPrecioGeneral = 10000000;

  final List<String> categories = [
    'Todos',
    'Tornillo',
    'Pistón',
    'Aceite',
    'Libres de Aire',
  ];

  @override
  void initState() {
    super.initState();
    // Si viene desde la pantalla de Inicio, pre-selecciona el chip correspondiente
    if (widget.categoriaInicial != null) {
      int index = categories.indexOf(widget.categoriaInicial!);
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
    _cargarProductosIniciales();
  }

  // Carga inicial para determinar marcas dinámicas y rango de precios
  Future<void> _cargarProductosIniciales() async {
    _cargarProductos();
    try {
      final base = await _productoService.filterByParams();
      if (mounted && base.isNotEmpty) {
        // 🚀 Filtramos únicamente los productos activos (no suspendidos)
        final productosActivos = base.where((p) => !p.suspendido).toList();

        if (productosActivos.isEmpty) return;

        final marcasSet = productosActivos
            .map((p) => p.marca.trim())
            .where((m) => m.isNotEmpty)
            .toSet();

        double min = productosActivos.first.precio;
        double max = productosActivos.first.precio;
        for (var p in productosActivos) {
          if (p.precio < min) min = p.precio;
          if (p.precio > max) max = p.precio;
        }

        if (min == max) max = min + 100000;

        setState(() {
          _todosLosProductos = productosActivos;
          _marcasDisponibles = marcasSet.toList()..sort();
          _minPrecioGeneral = min;
          _maxPrecioGeneral = max;
          _rangoPrecioSeleccionado = RangeValues(min, max);
        });
      }
    } catch (_) {}
  }

  void _cargarProductos() {
    final categoria = categories[_selectedCategoryIndex];
    setState(() {
      _futureProductos = _productoService
          .filterByParams(
        tipo: categoria == 'Todos' ? null : categoria,
      )
          .then((productos) {
        return productos.where((p) {
          // 🚀 Regla estricta: Si está suspendido, se descarta de inmediato
          if (p.suspendido) return false;

          final cumpleMarca = _marcaSeleccionada == null ||
              p.marca.toLowerCase() == _marcaSeleccionada!.toLowerCase();

          final cumplePrecio = _rangoPrecioSeleccionado == null ||
              (p.precio >= _rangoPrecioSeleccionado!.start &&
                  p.precio <= _rangoPrecioSeleccionado!.end);

          return cumpleMarca && cumplePrecio;
        }).toList();
      });
    });
  }

  bool get _hayFiltrosActivos =>
      _marcaSeleccionada != null ||
      (_rangoPrecioSeleccionado != null &&
          (_rangoPrecioSeleccionado!.start > _minPrecioGeneral ||
              _rangoPrecioSeleccionado!.end < _maxPrecioGeneral));

  void _abrirModalFiltros() {
    String? tempMarca = _marcaSeleccionada;
    RangeValues tempRango = _rangoPrecioSeleccionado ??
        RangeValues(_minPrecioGeneral, _maxPrecioGeneral);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filtrar Productos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F2537),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempMarca = null;
                            tempRango = RangeValues(
                              _minPrecioGeneral,
                              _maxPrecioGeneral,
                            );
                          });
                        },
                        child: const Text(
                          'Restablecer',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  const Text('Rango de Precio', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF222222))),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$${tempRango.start.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE59819))),
                      Text('\$${tempRango.end.toStringAsFixed(0)} COP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFFE59819))),
                    ],
                  ),
                  RangeSlider(
                    values: tempRango,
                    min: _minPrecioGeneral,
                    max: _maxPrecioGeneral,
                    divisions: 20,
                    activeColor: const Color(0xFFFDB913),
                    inactiveColor: Colors.grey.shade300,
                    onChanged: (valores) {
                      setModalState(() {
                        tempRango = valores;
                      });
                    },
                  ),
                  const SizedBox(height: 14),

                  const Text('Marcas Disponibles', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF222222))),
                  const SizedBox(height: 10),
                  _marcasDisponibles.isEmpty
                      ? const Text('Cargando marcas...', style: TextStyle(color: Colors.grey, fontSize: 12))
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _marcasDisponibles.map((marca) {
                            final bool seleccionada = tempMarca == marca;
                            return ChoiceChip(
                              label: Text(marca),
                              selected: seleccionada,
                              selectedColor: const Color(0xFF222222),
                              backgroundColor: Colors.grey.shade100,
                              labelStyle: TextStyle(
                                color: seleccionada ? const Color(0xFFFDB913) : Colors.black87,
                                fontWeight: seleccionada ? FontWeight.bold : FontWeight.w500,
                                fontSize: 12,
                              ),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide.none),
                              onSelected: (bool select) {
                                setModalState(() {
                                  tempMarca = select ? marca : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFDB913),
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        setState(() {
                          _marcaSeleccionada = tempMarca;
                          _rangoPrecioSeleccionado = tempRango;
                        });
                        Navigator.pop(context);
                        _cargarProductos();
                      },
                      child: const Text('APLICAR FILTROS', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Route _crearRutaBusquedaDeslizante() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(position: offsetAnimation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 380),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    // Si se abrió desde la pantalla principal, mostramos el botón de regresar
    final bool modoSecundario = widget.categoriaInicial != null || widget.showBackButton;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      // Agregamos un AppBar nativo si es una vista secundaria superpuesta
      appBar: modoSecundario
          ? AppBar(
              backgroundColor: const Color(0xFFF7F8FA),
              elevation: 0,
              centerTitle: true,
              title: Text(
                widget.categoriaInicial ?? 'Catálogo',
                style: const TextStyle(color: Color(0xFF1E242B), fontWeight: FontWeight.w900, fontSize: 16),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E242B)),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                // 🚀 Botón para saltar directamente a MainNavigation
                IconButton(
                  icon: const Icon(Icons.grid_view_rounded, color: Color(0xFF1E242B)),
                  tooltip: 'Ir al menú principal',
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainNavigation()),
                      (route) => false,
                    );
                  },
                ),
              ],
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await _cargarProductosIniciales();
        },
        color: const Color(0xFFFDB913),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.only(
            // Ajustamos el padding dinámicamente
            top: modoSecundario ? 16 : topPadding + 65,
            bottom: modoSecundario ? bottomPadding + 20 : bottomPadding + 90,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de búsqueda con botón de filtros integrado
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, _crearRutaBusquedaDeslizante())
                            .then((_) => _cargarProductos());
                      },
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFF7A837E), size: 22),
                            const SizedBox(width: 10),
                            Text(
                              'Buscar compresores, repuestos...',
                              style: TextStyle(fontSize: 13.5, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Botón de Filtros
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: _hayFiltrosActivos ? const Color(0xFF222222) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _hayFiltrosActivos ? const Color(0xFF222222) : Colors.black.withValues(alpha: 0.08),
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 3)),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.tune_rounded,
                        color: _hayFiltrosActivos ? const Color(0xFFFDB913) : const Color(0xFF222222),
                        size: 22,
                      ),
                      onPressed: _abrirModalFiltros,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Chips de categoría
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedCategoryIndex == index;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                        _cargarProductos();
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF222222) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF222222) : Colors.black.withValues(alpha: 0.08),
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 3))]
                              : null,
                        ),
                        child: Text(
                          categories[index],
                          style: TextStyle(
                            color: isSelected ? const Color(0xFFFDB913) : const Color(0xFF555555),
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Chips informativos si hay filtros aplicados
              if (_hayFiltrosActivos) ...[
                Row(
                  children: [
                    const Text('Filtros aplicados:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black54)),
                    const SizedBox(width: 8),
                    if (_marcaSeleccionada != null)
                      Chip(
                        label: Text(_marcaSeleccionada!),
                        backgroundColor: Colors.white,
                        deleteIconColor: Colors.black54,
                        labelStyle: const TextStyle(fontSize: 11),
                        onDeleted: () {
                          setState(() {
                            _marcaSeleccionada = null;
                          });
                          _cargarProductos();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
              ],

              // Título y Conteo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Catálogo de Equipos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2537))),
                  FutureBuilder<List<ProductoModel>>(
                    future: _futureProductos,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;
                      return Text('$count productos', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF7A837E)));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Lista de productos filtrados
              FutureBuilder<List<ProductoModel>>(
                future: _futureProductos,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: CircularProgressIndicator(color: Color(0xFFFDB913)),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red, size: 40),
                            const SizedBox(height: 8),
                            Text('Error: ${snapshot.error}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton(onPressed: _cargarProductos, child: const Text('Reintentar', style: TextStyle(color: Color(0xFFFDB913)))),
                          ],
                        ),
                      ),
                    );
                  }

                  final productos = snapshot.data ?? [];

                  if (productos.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Text('No se encontraron productos con estos filtros.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ),
                    );
                  }

                  return Column(
                    children: productos.map((producto) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ProductoCard(
                          producto: producto,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetalleProductoPage(
                                  nombre: producto.nombre,
                                  marca: producto.marca,
                                  precio: '\$${producto.precio.toStringAsFixed(0)}',
                                  imagenUrl: producto.imagenUrl ?? '',
                                  descripcion: producto.caracteristicas.isNotEmpty ? producto.caracteristicas : 'Sin descripción técnica disponible.',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}