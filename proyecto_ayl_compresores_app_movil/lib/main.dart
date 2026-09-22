import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Carga de variables de entorno
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('Advertencia: No se pudo cargar el archivo .env: $e');
  }

  // 2. Inicialización de Supabase
  await SupabaseService.initialize();

  // Si el usuario abrió la app desde el enlace del correo, lo enviamos a actualizar su clave
  Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    final AuthChangeEvent event = data.event;
    if (event == AuthChangeEvent.passwordRecovery) {
      navigatorKey.currentState?.pushNamed('/update_password');
    }
  });

  runApp(const MiApp());
}