import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para usar kIsWeb
import 'package:http/http.dart' as http;
import 'package:proyecto_ayl_compresores_app_movil/models/bitacora/bitacora_model.dart';

class BitacoraService {
  static final String _baseUrl = kIsWeb 
      ? 'http://localhost:3001/api/bitacora' 
      : 'http://10.0.2.2:3001/api/bitacora';

  static Future<List<MovimientoBitacora>> obtenerMovimientos({String? accion, String? modulo}) async {
    try {
      final queryParams = <String, String>{};
      if (accion != null && accion.isNotEmpty) queryParams['accion'] = accion;
      if (modulo != null && modulo.isNotEmpty) queryParams['modulo'] = modulo;

      final uri = Uri.parse(_baseUrl).replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => MovimientoBitacora.fromJson(item)).toList();
      } else {
        throw Exception('Error del servidor: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Fallo al conectar con la API: $e');
    }
  }
}