import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Espera 3 segundos y navega a la pantalla de navegación principal
    Future.delayed(Duration(seconds: 3), () {
      // pushReplacement quita el splash screen para que el usuario no pueda "volver" a él
      Navigator.pushReplacementNamed(context, '/home'); 
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Color oscuro basado en tu diseño web
      body: Center(
        // Aquí luego pondremos el logo de A&L
        child: Text(
          'A&L Compresores y Partes', 
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}