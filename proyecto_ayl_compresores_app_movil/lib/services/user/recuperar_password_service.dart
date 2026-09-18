import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RecuperarPasswordService {
  static final _supabase = Supabase.instance.client;

  /// Valida si el correo existe en la base de datos y envía el enlace de recuperación de Supabase
  static Future<bool> enviarEnlaceRecuperacion(String correo) async {
    final emailLimpio = correo.trim().toLowerCase();

    try {
      // 1. Validar si el usuario existe realmente en la tabla 'usuario'
      final usuarioExistente = await _supabase
          .from('usuario')
          .select('correo')
          .ilike('correo', emailLimpio)
          .maybeSingle();

      if (usuarioExistente == null) {
        throw Exception('Este correo no está registrado en el sistema.');
      }

      // 2. Enviar el correo de recuperación mediante Supabase Auth
      await _supabase.auth.resetPasswordForEmail(emailLimpio);
      debugPrint('RecuperarPasswordService: Enlace enviado con éxito a $emailLimpio');
      return true;
    } catch (e) {
      debugPrint('RecuperarPasswordService Error: $e');
      rethrow;
    }
  }
}