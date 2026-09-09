import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'usuario_service.dart';

class AuthHelper {
  /// Determina de forma precisa y robusta el rol del usuario autenticado
  static Future<String> obtenerRolUsuario({User? user}) async {
    final currentUser = user ?? Supabase.instance.client.auth.currentUser;
    if (currentUser == null) return 'invitado';

    final email = (currentUser.email ?? '').trim().toLowerCase();
    final prefs = await SharedPreferences.getInstance();

    debugPrint('AuthHelper: Verificando rol para ${currentUser.email} (${currentUser.id})');
    debugPrint('AuthHelper: userMetadata = ${currentUser.userMetadata}');
    debugPrint('AuthHelper: appMetadata = ${currentUser.appMetadata}');

    // 1. Revisar userMetadata
    final userMeta = currentUser.userMetadata ?? {};
    final metaRol = (userMeta['rol'] ??
            userMeta['role'] ??
            userMeta['tipo'] ??
            userMeta['perfil'] ??
            userMeta['tipo_usuario'])
        ?.toString()
        .toLowerCase()
        .trim();

    if (metaRol != null &&
        metaRol.isNotEmpty &&
        metaRol != 'authenticated' &&
        metaRol != 'anon') {
      debugPrint('AuthHelper: Rol encontrado en userMetadata: $metaRol');
      if (['admin', 'administrador'].contains(metaRol)) {
        await prefs.setString('user_role', 'admin');
        return 'admin';
      }
      if (metaRol == 'empleado') {
        await prefs.setString('user_role', 'empleado');
        return 'empleado';
      }
    }

    // 2. Revisar appMetadata (filtrando los roles por defecto de Supabase 'authenticated' y 'anon')
    final appMeta = currentUser.appMetadata;
    final appRol = (appMeta['rol'] ??
            appMeta['user_role'] ??
            appMeta['custom_role'] ??
            (appMeta['role'] != 'authenticated' && appMeta['role'] != 'anon'
                ? appMeta['role']
                : null))
        ?.toString()
        .toLowerCase()
        .trim();

    if (appRol != null && appRol.isNotEmpty) {
      debugPrint('AuthHelper: Rol encontrado en appMetadata: $appRol');
      if (['admin', 'administrador'].contains(appRol)) {
        await prefs.setString('user_role', 'admin');
        return 'admin';
      }
    }

    // 3. Consultar en la base de datos Supabase (tabla 'usuario')
    try {
      Map<String, dynamic>? userDb;

      // Intento A: Por ID en tabla 'usuario' (con timeout de 3s para que no bloquee)
      try {
        userDb = await Supabase.instance.client
            .from('usuario')
            .select('rol, nombre')
            .eq('id', currentUser.id)
            .maybeSingle()
            .timeout(const Duration(seconds: 3));
      } catch (e) {
        debugPrint('AuthHelper: Consulta usuario por ID en tabla usuario: $e');
      }

      // Intento B: Por correo en tabla 'usuario'
      if (userDb == null && email.isNotEmpty) {
        try {
          userDb = await Supabase.instance.client
              .from('usuario')
              .select('rol, nombre')
              .ilike('correo', email)
              .maybeSingle()
              .timeout(const Duration(seconds: 3));
        } catch (e) {
          debugPrint('AuthHelper: Consulta usuario por correo en tabla usuario: $e');
        }
      }

      // Intento C: Fallback si la tabla tuviera nombre en plural 'usuarios'
      if (userDb == null) {
        try {
          userDb = await Supabase.instance.client
              .from('usuarios')
              .select('rol, nombre')
              .eq('id', currentUser.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 2));
        } catch (_) {}
      }

      if (userDb != null && userDb['rol'] != null) {
        final rolDb = userDb['rol'].toString().toLowerCase().trim();
        debugPrint('AuthHelper: ¡Rol encontrado en BD Supabase!: $rolDb');
        if (['admin', 'administrador'].contains(rolDb)) {
          await prefs.setString('user_role', 'admin');
          return 'admin';
        }
        if (rolDb == 'empleado') {
          await prefs.setString('user_role', 'empleado');
          return 'empleado';
        }
        if (rolDb.isNotEmpty && rolDb != 'authenticated') {
          await prefs.setString('user_role', rolDb);
          return rolDb;
        }
      }
    } catch (e) {
      debugPrint('AuthHelper: Error al consultar rol en BD Supabase: $e');
    }

    // 5. Consultar en backend REST API (UsuarioService con timeout rápido de 2s)
    try {
      if (email.isNotEmpty) {
        final usuariosApi = await UsuarioService.buscarUsuarios(email)
            .timeout(const Duration(seconds: 2));
        if (usuariosApi.isNotEmpty) {
          final usuario = usuariosApi.firstWhere(
            (u) => u.correo.toLowerCase() == email || u.id == currentUser.id,
            orElse: () => usuariosApi.first,
          );
          final rolApi = usuario.rol.toLowerCase().trim();
          debugPrint('AuthHelper: Rol encontrado en UsuarioService API: $rolApi');
          if (['admin', 'administrador'].contains(rolApi)) {
            await prefs.setString('user_role', 'admin');
            return 'admin';
          }
          if (rolApi.isNotEmpty) {
            await prefs.setString('user_role', rolApi);
            return rolApi;
          }
        }
      }
    } catch (e) {
      debugPrint('AuthHelper: Consulta UsuarioService API no disponible: $e');
    }

    // 6. Revisar SharedPreferences (si se había guardado un rol previamente)
    final savedRole = prefs.getString('user_role')?.toLowerCase().trim();
    if (savedRole != null &&
        savedRole.isNotEmpty &&
        savedRole != 'authenticated' &&
        savedRole != 'anon') {
      debugPrint('AuthHelper: Usando rol guardado en SharedPreferences: $savedRole');
      return savedRole;
    }

    // Por defecto: cliente
    debugPrint('AuthHelper: Asignando rol cliente por defecto.');
    await prefs.setString('user_role', 'cliente');
    return 'cliente';
  }

  /// Verifica si el usuario actual es administrador (priorizando caché rápida)
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

  /// Asegura que el usuario autenticado exista en la tabla 'usuario' de Supabase
  static Future<void> asegurarRegistroUsuario(User user) async {
    try {
      final email = user.email ?? '';
      if (email.isEmpty) return;

      final existing = await Supabase.instance.client
          .from('usuario')
          .select('id')
          .eq('id', user.id)
          .maybeSingle()
          .timeout(const Duration(seconds: 3));

      if (existing == null) {
        final nombre = obtenerNombre(user);
        final rol = (user.userMetadata?['rol'] ?? 'cliente').toString();

        await Supabase.instance.client.from('usuario').upsert({
          'id': user.id,
          'nombre': nombre,
          'correo': email,
          'rol': rol,
          'suspendido': false,
          'creado_en': DateTime.now().toIso8601String(),
          'actualizado_en': DateTime.now().toIso8601String(),
        }).timeout(const Duration(seconds: 4));
        debugPrint('AuthHelper: Usuario $email sincronizado con tabla usuario de Supabase');
      }
    } catch (e) {
      debugPrint('AuthHelper: Error al asegurar registro de usuario en Supabase: $e');
    }
  }

  /// Cierra sesión de Supabase y limpia SharedPreferences
  static Future<void> cerrarSesion() async {
    // 1. Limpiar preferencias primero para que la UI se actualice inmediatamente
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      debugPrint('AuthHelper: error al limpiar SharedPreferences: $e');
    }
    
    // 2. Cerrar sesión en Supabase con un timeout para evitar que se demore por problemas de red
    try {
      await Supabase.instance.client.auth.signOut().timeout(const Duration(seconds: 2));
    } catch (e) {
      debugPrint('AuthHelper: error en signOut Supabase: $e');
    }
  }
}
