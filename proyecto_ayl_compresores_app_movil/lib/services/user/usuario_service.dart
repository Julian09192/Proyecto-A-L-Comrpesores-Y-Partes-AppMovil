import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user/usuario_model.dart';

class UsuarioService {
  static const String baseUrl = 'http://192.168.1.49:3001/api';

  // Obtener Token guardado
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // 1. Obtener todos los usuarios
  static Future<List<Usuario>> obtenerUsuarios() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar usuarios');
    }
  }

  // 2. Actualizar Rol o Estado (Suspendido)
  static Future<bool> actualizarUsuario(String id, String rol, bool suspendido) async {
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
    );

    return response.statusCode == 200;
  }

  // 3. Buscar usuarios por nombre o correo
  static Future<List<Usuario>> buscarUsuarios(String query) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/usuarios/buscar?query=$query'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Error al buscar usuarios');
    }
  }
}