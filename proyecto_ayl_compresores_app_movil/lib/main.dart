import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importamos dotenv
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargamos las variables de entorno primero
  await dotenv.load(fileName: ".env");

  // 2. Inicializamos la conexión con Supabase
  await SupabaseService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MiApp();
  }
}