import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:proyecto_ayl_compresores_app_movil/screens/home/main_navigation.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const AYLApp());
}
=======
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importamos dotenv
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  // 1. Asegura que los componentes visuales estén listos antes de cargar cosas de internet
  WidgetsFlutterBinding.ensureInitialized();
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7

  // 2. Carga las llaves secretas de tu archivo .env
  await dotenv.load(fileName: ".env");

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A&L Compresores y Partes',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFFF5A623),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5A623),
          primary: const Color(0xFFF5A623),
        ),
      ),
      home: const MainNavigation(),
    );
  }
}
=======
  // 3. Inicializa la conexión con Supabase usando tu servicio
  await SupabaseService.initialize();

  // 4. Finalmente, arranca la aplicación visual
  runApp(const MiApp());
}
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
