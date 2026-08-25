import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para todos los campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // Para registro
  final _confirmPasswordController = TextEditingController(); // Para registro

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;
  
  // Estado para saber qué vista mostrar: 0 = Login, 1 = Registro, 2 = Recuperar
  int _vistaActual = 0; 

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNCIÓN PARA MOSTRAR NOTIFICACIONES (SNACKBARS) ---
  void _mostrarNotificacion(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje, style: const TextStyle(color: Colors.white)),
        backgroundColor: esError ? Colors.red.shade800 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo completamente limpio
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            // Si está en recuperar contraseña, volver al login
            if (_vistaActual == 2) {
              setState(() => _vistaActual = 0);
            } else {
              // Si está en login/registro, cerrar la pantalla y volver al inicio
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Título dinámico
              Text(
                _vistaActual == 0 ? '¡Hola de nuevo!' : 
                _vistaActual == 1 ? 'Únete a nosotros' : 'Recuperar Contraseña', 
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 5),
              Text(
                _vistaActual == 2 ? 'Te enviaremos un enlace para restablecerla' : 'Gestiona tus pedidos industriales', 
                style: const TextStyle(color: Colors.grey, fontSize: 15)
              ),
              const SizedBox(height: 30),

              // Pestañas (Solo se muestran si NO estamos en recuperar contraseña)
              if (_vistaActual != 2) ...[
                Row(
                  children: [
                    Expanded(child: _construirBotonPestana('INGRESAR', 0)),
                    Expanded(child: _construirBotonPestana('REGISTRARSE', 1)),
                  ],
                ),
                const Divider(height: 30, thickness: 1),
              ],

              // Formularios dinámicos
              if (_vistaActual == 0) _construirFormularioLogin(),
              if (_vistaActual == 1) _construirFormularioRegistro(),
              if (_vistaActual == 2) _construirFormularioRecuperar(),
            ],
          ),
        ),
      ),
    );
  }

  // --- PESTAÑAS SUPERIORES ---
  Widget _construirBotonPestana(String texto, int indice) {
    bool activo = _vistaActual == indice;
    return GestureDetector(
      onTap: () => setState(() {
        _vistaActual = indice;
        // Limpiamos los campos al cambiar de pestaña
        _emailController.clear();
        _passwordController.clear();
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: activo ? Colors.amber : Colors.transparent, width: 2)),
        ),
        child: Text(
          texto, 
          textAlign: TextAlign.center,
          style: TextStyle(
            color: activo ? Colors.amber.shade700 : Colors.grey, 
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }

  // --- VISTA 1: LOGIN ---
  Widget _construirFormularioLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(controller: _emailController, hint: 'Correo Electrónico', icono: Icons.email_outlined),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _passwordController, 
          hint: 'Contraseña', 
          esPassword: true, 
          ocultar: _ocultarPassword, 
          onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword)
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () => setState(() => _vistaActual = 2), // Cambia a vista recuperar
            child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.amber.shade700)),
          ),
        ),
        const SizedBox(height: 25),
        _construirBotonPrincipal('INICIAR SESIÓN', _ejecutarLogin),
      ],
    );
  }

  // --- VISTA 2: REGISTRO ---
  Widget _construirFormularioRegistro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(controller: _nameController, hint: 'Nombre de Usuario', icono: Icons.person_outline),
        const SizedBox(height: 15),
        _construirCampoTexto(controller: _emailController, hint: 'Correo Electrónico', icono: Icons.email_outlined),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _passwordController, 
          hint: 'Contraseña', 
          esPassword: true, 
          ocultar: _ocultarPassword, 
          onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword)
        ),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _confirmPasswordController, 
          hint: 'Confirmar Contraseña', 
          esPassword: true, 
          ocultar: _ocultarConfirmPassword, 
          onTapOjo: () => setState(() => _ocultarConfirmPassword = !_ocultarConfirmPassword)
        ),
        const SizedBox(height: 30),
        _construirBotonPrincipal('CREAR CUENTA GRATIS', () {
          // Lógica de registro pendiente
          _mostrarNotificacion('Función de registro en construcción');
        }),
      ],
    );
  }

  // --- VISTA 3: RECUPERAR CONTRASEÑA ---
  Widget _construirFormularioRecuperar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(controller: _emailController, hint: 'Correo Electrónico', icono: Icons.email_outlined),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                onPressed: () => setState(() => _vistaActual = 0), // Vuelve al login
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _construirBotonPrincipal('Enviar enlace', () {
                // Lógica de Supabase para enviar correo pendiente
                _mostrarNotificacion('Enlace enviado. Revisa tu carpeta de spam.');
                setState(() => _vistaActual = 0); // Vuelve al login tras enviar
              }),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
            SizedBox(width: 5),
            Text('Revisa la carpeta de spam si no recibes el correo', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        )
      ],
    );
  }

  // --- WIDGETS REUTILIZABLES ---
  Widget _construirCampoTexto({required TextEditingController controller, required String hint, bool esPassword = false, bool ocultar = false, VoidCallback? onTapOjo, IconData? icono}) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
        suffixIcon: esPassword 
          ? IconButton(icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onTapOjo) 
          : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
      ),
    );
  }

  Widget _construirBotonPrincipal(String texto, VoidCallback accion) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber,
        padding: const EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 0,
      ),
      onPressed: accion,
      child: Text(texto, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15)),
    );
  }

  // --- LÓGICA DE INICIO DE SESIÓN ---
  Future<void> _ejecutarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _mostrarNotificacion('Por favor llena todos los campos', esError: true);
      return;
    }

    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user != null) {
        _mostrarNotificacion('¡Inicio de sesión exitoso!');

        // Cierra la pantalla de login y limpia el stack de navegación
        if (mounted) {
          // Aquí más adelante validaremos el ROL (Admin/Empleado/Cliente)
          // Para avanzar al paso 2, simularemos que entra al dashboard de Admin
          Navigator.pushReplacementNamed(context, '/dashboard_admin');
        }
      }
    } on AuthException catch (e) {
      debugPrint("ERROR DE AUTENTICACIÓN SUPABASE: ${e.message}");
      _mostrarNotificacion(e.message, esError: true);
    } catch (e) {
      // ESTO IMPRIMIRÁ EL ERROR REAL EN TU CONSOLA DE VISUAL STUDIO CODE
      debugPrint("ERROR DE SUPABASE: $e");

      _mostrarNotificacion('Error: $e', esError: true);
    }
  }
}