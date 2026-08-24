import 'package:flutter/material.dart';
import 'app.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  // Asegura la inicialización del binding antes de llamadas asíncronas
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa la conexión con Supabase
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