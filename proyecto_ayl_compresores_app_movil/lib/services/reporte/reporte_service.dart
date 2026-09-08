import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto_ayl_compresores_app_movil/models/reportes/reporte_model.dart';

class ReporteService {
  // Ajusta el prefijo según tengas montado tu router en Express (ej. /api/reportes o /queries)
  static final String _baseUrl = kIsWeb
      ? 'http://localhost:3000/api/reportes/inventario'
      : 'http://10.0.2.2:3000/api/reportes/inventario';

  static Future<ReporteInventarioResponse> obtenerInventario({
    String tipoReporte = 'stock',
    String? categoria,
    String? proveedor,
    String? fechaInicio,
    String? fechaFin,
    String? token, // Si tu middleware verificarToken requiere Authorization header
  }) async {
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

      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return ReporteInventarioResponse.fromJson(data);
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar con la API de reportes: $e');
    }
  }
}