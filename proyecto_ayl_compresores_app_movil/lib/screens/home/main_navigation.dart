import 'package:flutter/material.dart';
<<<<<<< HEAD
=======
import 'package:proyecto_ayl_compresores_app_movil/screens/Login/login_screen.dart';
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
import 'inicio_view.dart';
import '../productos/productos_screen.dart';
import '../cart/cart_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
<<<<<<< HEAD
  int _currentIndex = 2;
=======
  int _currentIndex = 0;
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7

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
<<<<<<< HEAD
        title: Image.asset(
          'assets/logo-ayl.jpeg',
          height: 35,
=======
        title: Image.network(
          'PEGAR_AQUI_EL_LINK_DE_CLOUDINARY', // <-- Pon tu enlace real de Cloudinary aquí
          height: 35, // Altura del logo para que no se vea gigante
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
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
<<<<<<< HEAD
              // Aquí luego programaremos que se abra tu formulario de login
              // (donde entran el admin, empleado o cliente)
              debugPrint('Abrir Login');
=======
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
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
<<<<<<< HEAD

      // --- FIN DE LA BARRA SUPERIOR ---
=======
      // --- FIN DE LA BARRA SUPERIOR ---

>>>>>>> f8765c194c56f19b00f0a66df0d525ec6de4d8a7
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
