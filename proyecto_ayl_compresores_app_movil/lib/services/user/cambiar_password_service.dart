import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CambiarPasswordService {
  static final _supabase = Supabase.instance.client;

  /// Cambia la contraseña del usuario actualmente autenticado
  static Future<bool> cambiarPassword({
    required String passwordActual,
    required String nuevoPassword,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('No hay una sesión activa.');
    }

    try {
      // 1. Validar la contraseña actual intentando iniciar sesión de forma silenciosa
      await _supabase.auth.signInWithPassword(
        email: user.email!,
        password: passwordActual,
      );

      // 2. Si las credenciales son correctas, actualizamos a la nueva contraseña
      await _supabase.auth.updateUser(
        UserAttributes(password: nuevoPassword),
      );

      debugPrint('CambiarPasswordService: Contraseña actualizada con éxito');
      return true;
    } on AuthException catch (e) {
      debugPrint('CambiarPasswordService AuthError: ${e.message}');
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        throw Exception('La contraseña actual es incorrecta.');
      }
      throw Exception(e.message);
    } catch (e) {
      debugPrint('CambiarPasswordService Error: $e');
      rethrow;
    }
  }
}