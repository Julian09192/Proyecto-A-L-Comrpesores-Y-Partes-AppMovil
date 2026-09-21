import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../products/cart_service.dart';
import '../products/favoritos_service.dart';

class AuthHelper {
  /// Determina el rol del usuario consultando de forma directa y prioritaria la tabla 'usuario' de Supabase
  static Future<String> obtenerRolUsuario({User? user}) async {
    final currentUser = user ?? Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return 'invitado';

    final email = (currentUser.email ?? '').trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    debugPrint('AuthHelper: Consultando rol en BD para ID: ${currentUser.id} | Email: $email');

    // 1. Fuente de verdad principal: Consultar la tabla 'usuario' en Supabase
    try {
      Map<String, dynamic>? userDb;

      // Consulta por ID (Coincidencia exacta con el UUID de Auth)
      try {
        userDb = await Supabase.instance.client
            .from('usuario')
            .select('rol, nombre')
            .eq('id', currentUser.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('AuthHelper: Error al consultar por ID en tabla usuario: $e');
      }

      // Si no encontró por ID, intentamos por correo (ilike)
      if (userDb == null && email.isNotEmpty) {
        try {
          userDb = await Supabase.instance.client
              .from('usuario')
              .select('rol, nombre')
              .ilike('correo', email)
              .maybeSingle()
              .timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint('AuthHelper: Error al consultar por correo en tabla usuario: $e');
        }
      }

      if (userDb != null && userDb['rol'] != null) {
        final rolDb = userDb['rol'].toString().toLowerCase().trim();
        debugPrint('AuthHelper: ¡Rol encontrado exitosamente en BD Supabase!: $rolDb');
        
        if (rolDb.isNotEmpty) {
          await prefs.setString('user_role', rolDb);
          return rolDb; // Devuelve exactamente 'admin', 'empleado' o 'cliente' según esté en la tabla
        }
      }
    } catch (e) {
      debugPrint('AuthHelper: Excepción general al consultar rol en BD Supabase: $e');
    }

    // 2. Respaldo por Caché local (SharedPreferences) si la red falla
    final savedRole = prefs.getString('user_role')?.toLowerCase().trim();
    if (savedRole != null && savedRole.isNotEmpty && savedRole != 'authenticated') {
      debugPrint('AuthHelper: Usando rol respaldado en SharedPreferences: $savedRole');
      return savedRole;
    }

    // Por defecto si no se encuentra en ningún lado: cliente
    debugPrint('AuthHelper: No se pudo verificar en BD, asignando rol por defecto: cliente');
    await prefs.setString('user_role', 'cliente');
    return 'cliente';
  }

  /// Verifica si el usuario actual es administrador
  static Future<bool> esAdmin({User? user}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRole = prefs.getString('user_role')?.toLowerCase().trim();
    if (savedRole != null && (savedRole == 'admin' || savedRole == 'administrador')) {
      return true;
    }
    final rol = await obtenerRolUsuario(user: user);
    return rol == 'admin' || rol == 'administrador';
  }

  /// Obtiene el nombre formateado del usuario
  static String obtenerNombre(User? user) {
    if (user == null) return 'Usuario';
    return user.userMetadata?['nombre'] ??
        user.userMetadata?['full_name'] ??
        user.userMetadata?['name'] ??
        user.email?.split('@').first ??
        'Usuario';
  }

  /// Asegura que el usuario autenticado exista en la tabla 'usuario' de Supabase al iniciar sesión
  static Future<void> asegurarRegistroUsuario(User user) async {
    try {
      final email = (user.email ?? '').trim().toLowerCase();
      if (email.isEmpty) return;

      // Verificamos si ya existe el registro en la tabla 'usuario'
      final existing = await Supabase.instance.client
          .from('usuario')
          .select('id, rol')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      final nombre = obtenerNombre(user);

      if (existing == null) {
        // Si no existe, lo creamos por defecto como cliente (o el rol que traiga en metadata si aplica)
        final rolInicial = (user.userMetadata?['rol'] ?? 'cliente').toString().toLowerCase();

        await Supabase.instance.client.from('usuario').upsert({
          'id': user.id,
          'nombre': nombre,
          'correo': email,
          'rol': rolInicial,
          'suspendido': false,
          'creado_en': DateTime.now().toIso8601String(),
          'actualizado_en': DateTime.now().toIso8601String(),
        }).timeout(const Duration(seconds: 4));
        
        debugPrint('AuthHelper: Nuevo usuario insertado en tabla usuario con rol: $rolInicial');
      } else {
        // Si ya existe, actualizamos la fecha de actividad y conservamos su rol real de la base de datos
        await Supabase.instance.client
            .from('usuario')
            .update({'actualizado_en': DateTime.now().toIso8601String()})
            .eq('id', user.id);
      }
    } catch (e) {
      debugPrint('AuthHelper: Error al asegurar registro de usuario en Supabase: $e');
    }
  }

  /// Cierra sesión de Supabase y limpia SharedPreferences
  static Future<void> cerrarSesion() async {
    CartService().limpiarMemoriaLogout();
    FavoritosService().limpiarMemoriaLogout();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('AuthHelper: error al limpiar SharedPreferences: $e');
    }
    
    try {
      await Supabase.instance.client.auth.signOut().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('AuthHelper: error en signOut Supabase: $e');
    }
  }
}