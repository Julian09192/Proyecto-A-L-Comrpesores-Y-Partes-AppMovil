import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Leemos las llaves del archivo .env usando el nombre de la variable
    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ??
        dotenv.env['VITE_SUPABASE_URL'] ??
        '';
    final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ??
        dotenv.env['VITE_SUPABASE_ANON_KEY'] ??
        '';

    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw Exception(
        '⚠️ Error: No se encontró SUPABASE_URL o SUPABASE_ANON_KEY en el archivo .env',
      );
    }

    // Inicializamos Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
    );
  }

  // Atajo para usar el cliente en otras partes de tu app
  static SupabaseClient get client => Supabase.instance.client;
}
