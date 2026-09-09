import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/user/usuario_model.dart';

class UsuarioService {
  static const String baseUrl = 'http://192.168.1.38:3001/api';

  // Obtener Token guardado
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 1. Obtener todos los usuarios (intenta API con timeout de 2s, sino usa Supabase)
  static Future<List<Usuario>> obtenerUsuarios() async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('UsuarioService API no disponible ($e). Consultando directamente Supabase...');
    }

    // Fallback: Supabase directo (tabla 'usuario')
    try {
      final data = await Supabase.instance.client
          .from('usuario')
          .select('*')
          .order('creado_en', ascending: false)
          .timeout(const Duration(seconds: 4));
      return (data as List).map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error al consultar usuarios en Supabase: $e');
      throw Exception('Error al cargar usuarios');
    }
  }

  // 2. Actualizar Rol o Estado (Suspendido)
  static Future<bool> actualizarUsuario(String id, String rol, bool suspendido) async {
    try {
      final token = await _getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/usuarios/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'rol': rol,
          'suspendido': suspendido,
        }),
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) return true;
    } catch (e) {
      debugPrint('UsuarioService API no disponible para actualizar. Guardando en Supabase...');
    }

    // Fallback: Actualizar directamente en Supabase
    try {
      await Supabase.instance.client
          .from('usuario')
          .update({
            'rol': rol,
            'actualizado_en': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .timeout(const Duration(seconds: 4));
      return true;
    } catch (e) {
      debugPrint('Error al actualizar en Supabase: $e');
      return false;
    }
  }

  // 3. Buscar usuarios por nombre o correo
  static Future<List<Usuario>> buscarUsuarios(String query) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/usuarios/buscar?query=$query'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Usuario.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint('UsuarioService API buscarUsuarios no disponible: $e');
    }

    // Fallback: Buscar en Supabase
    try {
      final data = await Supabase.instance.client
          .from('usuario')
          .select('*')
          .or('nombre.ilike.%$query%,correo.ilike.%$query%')
          .timeout(const Duration(seconds: 4));
      return (data as List).map((json) => Usuario.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error al buscar en Supabase: $e');
      return [];
    }
  }
}