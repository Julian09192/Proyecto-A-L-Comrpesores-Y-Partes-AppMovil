import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _ocultarPassword = true;

  // 1. Agregamos el método dispose para limpiar la memoria al salir de la pantalla
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E24), // Fondo oscuro de la imagen
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20), // Bordes redondeados
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('¡Hola de nuevo!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Gestiona tus pedidos industriales', style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 25),
                
                // Pestañas visuales (Ingresar / Registrarse)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('INGRESAR', style: TextStyle(color: Colors.amber.shade600, fontWeight: FontWeight.bold)),
                    const Text('REGISTRARSE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
                
                // Campos de texto
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Correo Electrónico',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                      onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Olvidaste contraseña
                Align(
                  alignment: Alignment.centerRight,
                  child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.amber.shade600)),
                ),
                const SizedBox(height: 25),
                
                // 2. Botón Iniciar Sesión conectado a Supabase
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    // Extraemos el texto escrito
                    final email = _emailController.text.trim();
                    final password = _passwordController.text.trim();

                    // Validación básica
                    if (email.isEmpty || password.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Por favor llena todos los campos')),
                      );
                      return; // Detiene la ejecución si hay campos vacíos
                    }

                    try {
                      // Intento de conexión con Supabase
                      final response = await Supabase.instance.client.auth.signInWithPassword(
                        email: email,
                        password: password,
                      );

                      if (response.user != null) {
                        print("Usuario logueado con éxito: ${response.user!.email}");
                        // Si es correcto, navega a la pantalla principal
                        Navigator.pushReplacementNamed(context, '/home'); 
                      }
                    } catch (e) {
                      // Si falla (contraseña incorrecta, etc.), muestra una alerta
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Credenciales incorrectas o error de conexión.')),
                      );
                    }
                  },
                  child: const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}