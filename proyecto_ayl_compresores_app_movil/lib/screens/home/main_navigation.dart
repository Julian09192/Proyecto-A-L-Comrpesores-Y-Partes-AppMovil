import 'package:flutter/material.dart';
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
import 'inicio_view.dart';
import '../productos/productos_screen.dart';
import '../cart/cart_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _vistas = [
    const InicioView(), // Tu vista de inicio
    const Center(child: Text('Contenido de Nosotros')),
    const ProductsScreen(),
    const Center(child: Text('Contenido de Contactos')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // --- NUEVA BARRA SUPERIOR (AppBar) ---
      appBar: AppBar(
        backgroundColor: const Color(0xFF222222), // El color oscuro de tu marca
        elevation: 0, // Quita la sombra para que se vea más moderno
        // 1. Aquí va tu logo a la izquierda
        title: Image.network(
          'PEGAR_AQUI_EL_LINK_DE_CLOUDINARY', // <-- Pon tu enlace real de Cloudinary aquí
          height: 35, // Altura del logo para que no se vea gigante
          errorBuilder: (context, error, stackTrace) => const Text(
            'A&L',
            style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          ),
        ),

        // 2. Aquí van los botones de la derecha (Usuario y Carrito)
        actions: [
          // Botón de Login / Usuario
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
          // Botón del Carrito de Compras
          IconButton(
            icon: const Icon(
              Icons.shopping_cart,
              color: Colors.amber,
            ), // Amarillo para destacar
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          const SizedBox(
            width: 10,
          ), // Un pequeño espacio al final para que no quede pegado al borde
        ],
      ),
      // --- FIN DE LA BARRA SUPERIOR ---

      body: _vistas[_currentIndex], // Muestra la vista seleccionada

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: 'Nosotros'),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: 'Productos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contactos',
          ),
        ],
      ),
    );
  }
}
