import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static Future<void> initialize() async {
    // Leemos las llaves del archivo .env
    final String supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    final String supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

    // Inicializamos Supabase
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }
  
  // Puedes crear un atajo para usar el cliente en otras partes de tu app
  static final client = Supabase.instance.client;
}