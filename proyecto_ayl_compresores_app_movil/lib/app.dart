import 'package:flutter/material.dart';
// Asegúrate de que las rutas a tus archivos sean correctas según tu estructura
import 'screens/splash/splash_screen.dart'; 
import 'screens/home/main_navigation.dart';

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A&L Compresores y Partes',
      debugShowCheckedModeBanner: false, // Quita la molesta etiqueta roja de "DEBUG" en la esquina
      
      // Configuramos los colores globales de tu marca
      theme: ThemeData(
        primaryColor: Colors.amber, // El amarillo de tu logo
        scaffoldBackgroundColor: Colors.grey[100], // Un fondo un poco grisáceo para que resalten las tarjetas blancas
      ),
      
      // initialRoute le dice a la app: "Cuando abras, ve directo a esta ruta"
      initialRoute: '/splash',
      
      // Aquí definimos el "mapa" de las pantallas
      routes: {
        '/splash': (context) => SplashScreen(),
        '/home': (context) => MainNavigation(),
      },
    );
  }
}