import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_ayl_compresores_app_movil/models/reportes/reporte_model.dart';

class ReporteService {
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api/reportes/inventario'
      : 'http://10.0.2.2:3000/api/reportes/inventario';

  static Future<ReporteInventarioResponse> obtenerInventario({
    String tipoReporte = 'stock',
    String? categoria,
    String? proveedor,
    String? fechaInicio,
    String? fechaFin,
    String? token,
  }) async {
    // 1. Intentar con API HTTP si está disponible
    try {
      final queryParams = <String, String>{
        'tipo_reporte': tipoReporte,
      };

      if (categoria != null && categoria.isNotEmpty && categoria != 'todas') {
        queryParams['categoria'] = categoria;
      }
      if (proveedor != null && proveedor.isNotEmpty && proveedor != 'todos') {
        queryParams['proveedor'] = proveedor;
      }
      if (fechaInicio != null && fechaInicio.isNotEmpty) {
        queryParams['fecha_inicio'] = fechaInicio;
      }
      if (fechaFin != null && fechaFin.isNotEmpty) {
        queryParams['fecha_fin'] = fechaFin;
      }

      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ReporteInventarioResponse.fromJson(data);
      }
    } catch (e) {
      debugPrint('API HTTP no disponible, calculando reporte desde Supabase: $e');
    }

    // 2. Fallback directo a Supabase
    return _calcularReporteDesdeSupabase(
      categoria: categoria,
      proveedor: proveedor,
    );
  }

  static Future<ReporteInventarioResponse> _calcularReporteDesdeSupabase({
    String? categoria,
    String? proveedor,
  }) async {
    final supabase = Supabase.instance.client;
    var query = supabase.from('productos').select('*');

    final data = await query.order('id', ascending: false);
    final rawList = List<Map<String, dynamic>>.from(data as List);

    int totalProductos = 0;
    int stockTotal = 0;
    double valorTotal = 0.0;
    final Map<String, Map<String, dynamic>> categoriasMap = {};
    final Set<String> proveedoresSet = {};
    final List<ReporteProducto> productos = [];

    for (var item in rawList) {
      final p = ReporteProducto.fromJson(item);
      final cat = p.tipo.isNotEmpty ? p.tipo : 'General';
      final prov = p.marca.isNotEmpty ? p.marca : 'Genérico';

      proveedoresSet.add(prov);

      if (!categoriasMap.containsKey(cat)) {
        categoriasMap[cat] = {
          'categoria': cat,
          'productos': 0,
          'stock_total': 0,
          'valor_total': 0.0,
        };
      }

      categoriasMap[cat]!['productos'] =
          (categoriasMap[cat]!['productos'] as int) + 1;
      categoriasMap[cat]!['stock_total'] =
          (categoriasMap[cat]!['stock_total'] as int) + p.stockTotal;
      categoriasMap[cat]!['valor_total'] =
          (categoriasMap[cat]!['valor_total'] as double) +
              (p.precio * p.stockTotal);

      // Aplicar filtros si aplican
      bool coincideCat = (categoria == null ||
          categoria.isEmpty ||
          categoria == 'todas' ||
          cat.toLowerCase() == categoria.toLowerCase());
      bool coincideProv = (proveedor == null ||
          proveedor.isEmpty ||
          proveedor == 'todos' ||
          prov.toLowerCase() == proveedor.toLowerCase());

      if (coincideCat && coincideProv) {
        totalProductos++;
        stockTotal += p.stockTotal;
        valorTotal += (p.precio * p.stockTotal);
        productos.add(p);
      }
    }

    final categoriasLista = categoriasMap.values
        .map((c) => ReporteCategoria.fromJson(c))
        .toList();

    return ReporteInventarioResponse(
      tipoReporte: 'stock',
      resumen: ReporteResumen(
        totalProductos: totalProductos,
        stockTotal: stockTotal,
        valorTotal: valorTotal,
      ),
      categorias: categoriasLista,
      proveedores: proveedoresSet.toList(),
      productos: productos,
    );
  }
}