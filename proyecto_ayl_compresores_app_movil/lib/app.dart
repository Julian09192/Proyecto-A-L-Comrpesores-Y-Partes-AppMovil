import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/admin/admin_dashboard.dart';
import 'screens/splash/splash_screen.dart'; 
import 'screens/home/main_navigation.dart';

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A&L Compresores y Partes',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: Colors.amber, // El amarillo de tu logo
        scaffoldBackgroundColor: Colors.grey[100], // Un fondo un poco grisáceo para que resalten las tarjetas blancas
      ),
      
      // initialRoute le dice a la app: "Cuando abras, ve directo a esta ruta"
      initialRoute: '/splash',    
      
      // Aquí definimos el "mapa" de las pantallas
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MainNavigation(),
        '/dashboard_admin': (context) => const AdminDashboard(),
      },
    );
  }
}