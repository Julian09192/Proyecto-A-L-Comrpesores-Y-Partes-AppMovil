import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Carga las llaves secretas de tu archivo .env protegiéndolo para entornos Web
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Advertencia: No se pudo cargar el archivo .env: $e');
  }


  await SupabaseService.initialize();

  runApp(const MiApp());
}

