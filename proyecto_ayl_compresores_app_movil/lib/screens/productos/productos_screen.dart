import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../../services/products/cart_service.dart';
import '../../services/products/favoritos_service.dart';
import '../../widgets/product_card.dart';
import '../home/search_screen.dart';
import '../cart/cart_screen.dart';
import 'detail_product.dart';

class ProductsScreen extends StatefulWidget {
  final String? categoriaInicial;
  final String? marcaInicial; 
  final bool showBackButton;

  const ProductsScreen({
    super.key,
    this.categoriaInicial,
    this.marcaInicial,
    this.showBackButton = false,
  });

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  int _selectedCategoryIndex = 0;
  final ProductoService _productoService = ProductoService();
  final CartService _cartService = CartService();
  final FavoritosService _favoritosService = FavoritosService();

  late Future<List<ProductoModel>> _futureProductos;

  List<ProductoModel> _todosLosProductos = [];
  List<String> _marcasDisponibles = [];

  String? _marcaSeleccionada;
  RangeValues? _rangoPrecioSeleccionado;
  double _minPrecioGeneral = 0;
  double _maxPrecioGeneral = 10000000;

  final List<String> categories = [
    'Todos',
    'Favoritos',
    'Tornillo',
    'Pistón',
    'Aceite',
    'Filtros de Aire',
  ];

  @override
  void initState() {
    super.initState();
    FavoritosService().addListener(_onFavoritosChanged);
    _cartService.addListener(_actualizarContador);

    if (widget.categoriaInicial != null) {
      int index = categories.indexOf(widget.categoriaInicial!);
      if (index != -1) {
        _selectedCategoryIndex = index;
      }
    }
    
    if (widget.marcaInicial != null) {
      _marcaSeleccionada = widget.marcaInicial;
    }

    _cargarProductosIniciales();
  }

  @override
  void dispose() {
    _cartService.removeListener(_actualizarContador);
    FavoritosService().removeListener(_onFavoritosChanged);
    super.dispose();
  }

  void _onFavoritosChanged() {
    if (mounted) {
      _cargarProductos(); 
    }
  }
  
  void _actualizarContador() {
    if (mounted) setState(() {});
  }

  Future<void> _cargarProductosIniciales() async {
    _cargarProductos();
    try {
      final base = await _productoService.filterByParams();
      if (mounted && base.isNotEmpty) {
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

        _cargarProductos();
      }
    } catch (_) {}
  }

  void _cargarProductos() {
    final categoria = categories[_selectedCategoryIndex];
    setState(() {
      _futureProductos = Future.microtask(() async {
        List<ProductoModel> base;

        if (_todosLosProductos.isNotEmpty) {
          base = _todosLosProductos;
          if (categoria != 'Todos' && categoria != 'Favoritos') {
            base = base.where((p) => p.tipo.toLowerCase() == categoria.toLowerCase()).toList();
          }
        } else {
          base = await _productoService.filterByParams(
            tipo: (categoria == 'Todos' || categoria == 'Favoritos') ? null : categoria,
          );
        }

        List<ProductoModel> filtrados = base.where((p) {
          if (p.suspendido) return false;

          final cumpleMarca = _marcaSeleccionada == null ||
              p.marca.toLowerCase() == _marcaSeleccionada!.toLowerCase();

          final cumplePrecio = _rangoPrecioSeleccionado == null ||
              (p.precio >= _rangoPrecioSeleccionado!.start &&
                  p.precio <= _rangoPrecioSeleccionado!.end);

          return cumpleMarca && cumplePrecio;
        }).toList();

        // 🚀 FILTRO EXACTO DE FAVORITOS
        if (categoria == 'Favoritos') {
          final idsFavoritos = await _favoritosService.obtenerIdsFavoritos();
  
          filtrados = filtrados.where((p) {
            return idsFavoritos.contains(p.id.toString());
          }).toList();
        }

        return filtrados;
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
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2537)),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempMarca = null;
                            tempRango = RangeValues(_minPrecioGeneral, _maxPrecioGeneral);
                          });
                        },
                        child: const Text('Restablecer', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
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
    
    final bool modoSecundario = widget.categoriaInicial != null || widget.marcaInicial != null || widget.showBackButton;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      
      appBar: modoSecundario
          ? AppBar(
              backgroundColor: const Color(0xFFF7F8FA),
              elevation: 0,
              scrolledUnderElevation: 0,
              leadingWidth: 54,
              leading: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3238), size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              titleSpacing: 0,
              title: SizedBox(
                height: 32,
                child: Image.asset(
                  'assets/images/logo_ayl.png',
                  fit: BoxFit.contain,
                  alignment: Alignment.centerLeft,
                  errorBuilder: (context, error, stackTrace) => Image.network(
                    'https://res.cloudinary.com/duvoqozcl/image/upload/v1777394217/logo-ayl.png',
                    fit: BoxFit.contain,
                    alignment: Alignment.centerLeft,
                    errorBuilder: (context, error, stackTrace) => const Text(
                      'A&L COMPRESORES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF2C3238),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              actions: [
                SizedBox(
                  width: 44,
                  height: 44,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        splashRadius: 22,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 40,
                          minHeight: 40,
                        ),
                        icon: const Icon(
                          Icons.shopping_cart_outlined,
                          color: Color(0xFF2C3238),
                          size: 25,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CartScreen(),
                            ),
                          );
                        },
                      ),
                      if (_cartService.totalItemsCount > 0)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${_cartService.totalItemsCount}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9.5,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
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
            top: modoSecundario ? 16 : topPadding + 65,
            bottom: modoSecundario ? bottomPadding + 20 : bottomPadding + 90,
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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