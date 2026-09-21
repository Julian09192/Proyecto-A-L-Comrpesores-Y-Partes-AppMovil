import 'package:flutter/material.dart';
import 'screens/splash/splash_screen.dart'; 
import 'screens/home/main_navigation.dart';
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_productos.dart';
import 'screens/admin/admin_notificaciones.dart';
import 'screens/admin/admin_bitacora_view.dart';
import 'screens/admin/admin_usuarios_view.dart';
import 'screens/admin/admin_reportes_view.dart';
import 'screens/admin/admin_perfil_view.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/Login/login_screen.dart';

class MiApp extends StatelessWidget {
  const MiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A&L Compresores y Partes',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primaryColor: Colors.amber, 
        scaffoldBackgroundColor: Colors.grey[100], 
      ),
      
      // initialRoute le dice a la app: "Cuando abras, ve directo a esta ruta"
     initialRoute: '/splash',     
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => const MainNavigation(),
        // Añade una ruta raíz '/' por si Supabase redirige al dominio principal
        '/': (context) => const MainNavigation(), 
        '/dashboard_admin': (context) => const AdminDashboard(),
        '/admin_productos': (context) => const ProductsAdminScreen(),
        '/admin_notificaciones': (context) => const NotificationAdminScreen(),
        '/admin_bitacora': (context) => const AdminBitacoraView(),
        '/admin_usuarios': (context) => const AdminUsuariosView(),
        '/admin_reportes': (context) => const AdminReportesView(),
        '/admin_perfil': (context) => const AdminPerfilView(),
        '/cart': (context) => const CartScreen(),
        '/login': (context) => const LoginScreen(),
      },
    );
  }
}