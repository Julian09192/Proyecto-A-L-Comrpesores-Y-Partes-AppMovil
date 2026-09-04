import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/home/main_navigation.dart';
import 'package:proyecto_ayl_compresores_app_movil/services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
  runApp(const AYLApp());
}

class AYLApp extends StatelessWidget {
  const AYLApp({super.key});

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
