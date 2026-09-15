import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificacionService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3001/api/notificaciones';
    }
    return 'http://10.0.2.2:3001/api/notificaciones';
  }

  static Future<List<dynamic>> obtenerNotificaciones() async {
    try {
      final response = await http.get(Uri.parse(baseUrl)).timeout(const Duration(seconds: 2));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception();
    } catch (_) {
      // Carga directa desde Supabase capturando imagen_url
      final supabaseData = await Supabase.instance.client
          .from('notificaciones_stock')
          .select('*')
          .order('id', ascending: false);
      
      return supabaseData.map((n) {
        final nombre = n['nombre_producto'] ?? 'Producto';
        final initials = nombre.trim().length >= 2
            ? nombre.trim().substring(0, 2).toUpperCase()
            : 'AL';
            
        return {
          'id': n['id'].toString(),
          'initials': initials,
          'sku': 'SKU ID: #${n['producto_id']}',
          'title': 'Stock Crítico (${n['stock_registrado']} und.): $nombre',
          'units': '${n['stock_registrado']}',
          'date': n['creado_en'] ?? 'Inventario actual',
          'isNew': !(n['leido'] ?? false),
          'imagenUrl': n['imagen_url'] ?? '', // 👈 Capturamos la URL de la imagen de Supabase
          'showImageText': false,
        };
      }).toList();
    }
  }

  static Future<void> marcarTodasComoLeidas() async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/marcar-todas')).timeout(const Duration(seconds: 2));
      if (response.statusCode != 200) throw Exception();
    } catch (_) {
      await Supabase.instance.client
          .from('notificaciones_stock')
          .update({'leido': true})
          .eq('leido', false);
    }
  }

  static Future<void> marcarComoLeida(String id) async {
    try {
      await http.put(Uri.parse('$baseUrl/$id/leer')).timeout(const Duration(seconds: 2));
    } catch (_) {
      await Supabase.instance.client
          .from('notificaciones_stock')
          .update({'leido': true})
          .eq('id', int.parse(id));
    }
  }

  static Future<void> eliminarNotificacion(String id) async {
    try {
      await Supabase.instance.client
          .from('notificaciones_stock')
          .delete()
          .eq('id', int.parse(id));
    } catch (e) {
      debugPrint('Error al eliminar en Supabase: $e');
      try {
        await http.delete(Uri.parse('$baseUrl/$id')).timeout(const Duration(seconds: 2));
      } catch (_) {}
    }
  }
}