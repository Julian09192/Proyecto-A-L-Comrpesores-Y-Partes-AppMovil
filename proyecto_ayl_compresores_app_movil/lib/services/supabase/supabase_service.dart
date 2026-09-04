import 'package:supabase_flutter/supabase_flutter.dart';
<<<<<<< HEAD
class SupabaseService {
  static const String _supabaseUrl = 'https://adaiklmjaoajsyixpvgc.supabase.co';

  static const String _supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFkYWlrbG1qYW9hanN5aXhwdmdjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc5MzkyMDAsImV4cCI6MjA5MzUxNTIwMH0.XG_N9KAcm0q4QjPl_LzEpRqL4wjyLP2vtklaA5PFvDk';

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: _supabaseUrl,
      publishableKey: _supabaseAnonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}
=======
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
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
