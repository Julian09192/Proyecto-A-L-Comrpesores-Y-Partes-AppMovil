import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _verificarSesionYNavegar();
  }

  Future<void> _verificarSesionYNavegar() async {
    // Espera 2.5 segundos para mostrar el splash screen
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final esAdmin = await AuthHelper.esAdmin(user: user);
      if (!mounted) return;
      if (esAdmin) {
        Navigator.pushReplacementNamed(context, '/dashboard_admin');
        return;
      }
    }

    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    }
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