import 'package:flutter/material.dart';
import '../../models/products/producto_model.dart';
import '../../services/products/producto_service.dart';
import '../productos/productos_screen.dart';
import 'search_screen.dart';
import './barra_busqueda_touch.dart';
import './tarjeta_asistencia.dart';
import './seccion_marcas.dart';
import './categorias_principales.dart';
import './productos_destacados.dart';

class InicioView extends StatefulWidget {
	const InicioView({super.key});

	@override
	State<InicioView> createState() => _InicioViewState();
}

class _InicioViewState extends State<InicioView> {
	final ProductoService _productoService = ProductoService();
	late Future<List<ProductoModel>> _futureProductosDestacados;

	@override
	void initState() {
		super.initState();
		_futureProductosDestacados = _productoService.filterByParams();
	}

	Route _crearRutaBusquedaDeslizante() {
		return PageRouteBuilder(
			pageBuilder: (context, animation, secondaryAnimation) => const SearchScreen(),
			transitionsBuilder: (context, animation, secondaryAnimation, child) {
				const begin = Offset(1, 0);
				const end = Offset.zero;
				const curve = Curves.easeInOutCubic;
				final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
				return SlideTransition(position: animation.drive(tween), child: child);
			},
			transitionDuration: const Duration(milliseconds: 380),
		);
	}

	void _filtrarCategoria(String categoria) {
		Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen(categoriaInicial: categoria)));
	}

	void _filtrarMarca(String marca) {
		Navigator.push(context, MaterialPageRoute(builder: (_) => ProductsScreen(marcaInicial: marca)));
	}

	void _verTodasLasMarcas() {
		Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductsScreen()));
	}

	@override
	Widget build(BuildContext context) {
		final topPadding = MediaQuery.of(context).padding.top;
		final bottomPadding = MediaQuery.of(context).padding.bottom;

		return SingleChildScrollView(
			padding: EdgeInsets.only(top: topPadding + 65, bottom: bottomPadding + 90),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					BarraBusquedaTouch(onTap: () => Navigator.push(context, _crearRutaBusquedaDeslizante())),
					const SizedBox(height: 16),
					const TarjetaAsistencia(),
					const SizedBox(height: 22),
					SeccionMarcas(onMarcaSeleccionada: _filtrarMarca, onVerTodas: _verTodasLasMarcas),
					const SizedBox(height: 24),
					CategoriasPrincipales(onCategoriaTap: _filtrarCategoria),
					const SizedBox(height: 24),
					_construirTituloSeccion('Productos Destacados'),
					ProductosDestacados(futureProductos: _futureProductosDestacados),
					const SizedBox(height: 20),
				],
			),
		);
	}

	Widget _construirTituloSeccion(String titulo) {
		return Padding(
			padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
			child: Text(
				titulo,
				style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F2537)),
			),
		);
	}
}
