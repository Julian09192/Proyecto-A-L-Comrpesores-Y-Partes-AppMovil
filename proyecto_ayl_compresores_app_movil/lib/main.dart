import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importamos dotenv
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  // 1. Asegura que los componentes visuales estén listos antes de cargar cosas de internet
  WidgetsFlutterBinding.ensureInitialized();

<<<<<<< HEAD
  // 2. Carga las llaves secretas de tu archivo .env
  await dotenv.load(fileName: ".env");
=======
  // 2. Carga las llaves secretas de tu archivo .env protegiéndolo para entornos Web
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("Advertencia: No se pudo cargar el archivo .env: $e");
  }
>>>>>>> 5fb2496e60237204d66c3e49f2d2812ce83cd011

  // 3. Inicializa la conexión con Supabase usando tu servicio
  await SupabaseService.initialize();

  // 4. Finalmente, arranca la aplicación visual
  runApp(const MiApp());
<<<<<<< HEAD
}
=======
}
>>>>>>> 5fb2496e60237204d66c3e49f2d2812ce83cd011
