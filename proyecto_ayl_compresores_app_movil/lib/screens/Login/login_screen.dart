import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/user/auth_helper.dart';

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
  bool _isLoading = false;

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
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              esError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: esError ? Colors.red.shade800 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // --- VALIDACIÓN DE EMAIL CON REGEX ---
  bool _esEmailValido(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
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
            if (_isLoading) return;
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
                _vistaActual == 0
                    ? '¡Hola de nuevo!'
                    : _vistaActual == 1
                        ? 'Únete a nosotros'
                        : 'Recuperar Contraseña',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                _vistaActual == 2
                    ? 'Te enviaremos un enlace para restablecerla'
                    : _vistaActual == 1
                        ? 'Crea tu cuenta para gestionar tus compras'
                        : 'Gestiona tus pedidos industriales',
                style: const TextStyle(color: Colors.grey, fontSize: 15),
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
      onTap: () {
        if (_isLoading) return;
        setState(() {
          _vistaActual = indice;
          // Limpiamos contraseñas al alternar de pestaña para seguridad
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: activo ? Colors.amber : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: activo ? Colors.amber.shade700 : Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --- VISTA 1: LOGIN ---
  Widget _construirFormularioLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(
          controller: _emailController,
          hint: 'Correo Electrónico',
          icono: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _passwordController,
          hint: 'Contraseña',
          esPassword: true,
          ocultar: _ocultarPassword,
          onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword),
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _ejecutarLogin(),
        ),
        const SizedBox(height: 15),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : () => setState(() => _vistaActual = 2),
            child: Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(color: Colors.amber.shade700),
            ),
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
        _construirCampoTexto(
          controller: _nameController,
          hint: 'Nombre completo',
          icono: Icons.person_outline,
          keyboardType: TextInputType.name,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _emailController,
          hint: 'Correo Electrónico',
          icono: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _passwordController,
          hint: 'Contraseña (mínimo 6 caracteres)',
          esPassword: true,
          ocultar: _ocultarPassword,
          onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword),
          textInputAction: TextInputAction.next,
          enabled: !_isLoading,
        ),
        const SizedBox(height: 15),
        _construirCampoTexto(
          controller: _confirmPasswordController,
          hint: 'Confirmar Contraseña',
          esPassword: true,
          ocultar: _ocultarConfirmPassword,
          onTapOjo: () => setState(() => _ocultarConfirmPassword = !_ocultarConfirmPassword),
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _ejecutarRegistro(),
        ),
        const SizedBox(height: 30),
        _construirBotonPrincipal('CREAR CUENTA GRATIS', _ejecutarRegistro),
      ],
    );
  }

  // --- VISTA 3: RECUPERAR CONTRASEÑA ---
  Widget _construirFormularioRecuperar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(
          controller: _emailController,
          hint: 'Correo Electrónico',
          icono: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          enabled: !_isLoading,
          onSubmitted: (_) => _ejecutarRecuperarPassword(),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isLoading ? null : () => setState(() => _vistaActual = 0),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: _construirBotonPrincipal('Enviar enlace', _ejecutarRecuperarPassword),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.green, size: 16),
            SizedBox(width: 5),
            Text(
              'Revisa la carpeta de spam si no recibes el correo',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        )
      ],
    );
  }

  // --- WIDGETS REUTILIZABLES ---
  Widget _construirCampoTexto({
    required TextEditingController controller,
    required String hint,
    bool esPassword = false,
    bool ocultar = false,
    VoidCallback? onTapOjo,
    IconData? icono,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    bool enabled = true,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      enabled: enabled,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade200,
        prefixIcon: icono != null ? Icon(icono, color: Colors.grey) : null,
        suffixIcon: esPassword
            ? IconButton(
                icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                onPressed: onTapOjo,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.amber, width: 2),
        ),
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
      onPressed: _isLoading ? null : accion,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.black,
              ),
            )
          : Text(
              texto,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
    );
  }

  // --- LÓGICA DE REGISTRO CON VALIDACIONES COHERENTES ---
  Future<void> _ejecutarRegistro() async {
    final nombre = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // 1. Validar nombre
    if (nombre.isEmpty) {
      _mostrarNotificacion('Por favor ingresa tu nombre completo', esError: true);
      return;
    }
    if (nombre.length < 3) {
      _mostrarNotificacion('El nombre debe tener al menos 3 caracteres', esError: true);
      return;
    }
    final regexNombre = RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s]+$");
    if (!regexNombre.hasMatch(nombre)) {
      _mostrarNotificacion('El nombre solo debe contener letras y espacios', esError: true);
      return;
    }

    // 2. Validar correo electrónico
    if (email.isEmpty) {
      _mostrarNotificacion('Por favor ingresa tu correo electrónico', esError: true);
      return;
    }
    if (!_esEmailValido(email)) {
      _mostrarNotificacion('Ingresa un correo electrónico válido (ej: usuario@correo.com)', esError: true);
      return;
    }

    // 3. Validar contraseña
    if (password.isEmpty) {
      _mostrarNotificacion('Por favor ingresa una contraseña', esError: true);
      return;
    }
    if (password.length < 6) {
      _mostrarNotificacion('La contraseña debe tener al menos 6 caracteres', esError: true);
      return;
    }
    if (password.trim().isEmpty) {
      _mostrarNotificacion('La contraseña no puede contener únicamente espacios', esError: true);
      return;
    }

    // 4. Validar confirmación de contraseña
    if (confirmPassword.isEmpty) {
      _mostrarNotificacion('Por favor confirma tu contraseña', esError: true);
      return;
    }
    if (password != confirmPassword) {
      _mostrarNotificacion('Las contraseñas no coinciden', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 5. Petición a Supabase Auth para crear la cuenta
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'nombre': nombre,
          'full_name': nombre,
          'rol': 'cliente',
        },
      );

      final user = response.user;

      // VALIDACIÓN CRÍTICA: Detección de correo duplicado en Supabase
      // Si el correo ya existía previamente, Supabase devuelve identities vacío [] para proteger privacidad
      if (user != null && (user.identities == null || user.identities!.isEmpty)) {
        _mostrarNotificacion(
          'Este correo electrónico ya se encuentra registrado. Por favor inicia sesión.',
          esError: true,
        );
        if (mounted) {
          setState(() {
            _vistaActual = 0; // Llevar a pestaña de ingresar
            _passwordController.clear();
            _confirmPasswordController.clear();
          });
        }
        return;
      }

      if (user != null) {
        // Si Supabase devuelve una sesión activa directamente (email confirmation desactivada)
        if (response.session != null) {
          final prefs = await SharedPreferences.getInstance();
          final token = response.session?.accessToken ?? '';
          await prefs.setString('auth_token', token);
          await prefs.setString('user_id', user.id);
          await prefs.setString('user_name', nombre);
          await prefs.setString('user_email', email);
          await prefs.setString('user_role', 'cliente');

          _mostrarNotificacion('¡Cuenta creada con éxito! Bienvenido, $nombre');

          if (mounted) {
            _nameController.clear();
            _emailController.clear();
            _passwordController.clear();
            _confirmPasswordController.clear();

            // Navegar limpiando el stack
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        } else {
          // Si Supabase requiere confirmación de correo
          _mostrarNotificacion('¡Registro exitoso! Ya puedes iniciar sesión con tu cuenta.');

          if (mounted) {
            setState(() {
              _vistaActual = 0; // Cambiar a la pestaña de ingresar
              _passwordController.clear();
              _confirmPasswordController.clear();
            });
          }
        }
      }
    } on AuthException catch (e) {
      debugPrint("ERROR DE REGISTRO SUPABASE: ${e.message}");
      String mensajeError = e.message;
      final lower = e.message.toLowerCase();
      if (lower.contains('already registered') ||
          lower.contains('user already exists') ||
          lower.contains('already in use')) {
        mensajeError = 'Este correo electrónico ya se encuentra registrado. Por favor inicia sesión.';
      } else if (lower.contains('password')) {
        mensajeError = 'La contraseña no cumple los requisitos mínimos de seguridad.';
      } else if (lower.contains('rate limit')) {
        mensajeError = 'Demasiados intentos. Por favor espera unos momentos antes de reintentar.';
      } else if (lower.contains('invalid email')) {
        mensajeError = 'El formato del correo electrónico no es válido.';
      }
      _mostrarNotificacion(mensajeError, esError: true);
    } catch (e) {
      debugPrint("ERROR INESPERADO AL REGISTRAR: $e");
      _mostrarNotificacion('Ocurrió un error inesperado al registrar el usuario', esError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- LÓGICA DE INICIO DE SESIÓN CON MANEJO DE ROLES ---
  Future<void> _ejecutarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarNotificacion('Por favor llena todos los campos', esError: true);
      return;
    }

    if (!_esEmailValido(email)) {
      _mostrarNotificacion('Por favor ingresa un formato de correo electrónico válido', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Petición a Supabase
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;

      // 2. Si las credenciales son válidas
      if (user != null) {
        final prefs = await SharedPreferences.getInstance();
        final token = response.session?.accessToken ?? '';

        // Obtener nombre y rol de forma robusta
        final nombre = AuthHelper.obtenerNombre(user);
        final rol = await AuthHelper.obtenerRolUsuario(user: user);

        // Guardar datos en SharedPreferences para uso en la app
        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', user.id);
        await prefs.setString('user_name', nombre);
        await prefs.setString('user_email', user.email ?? '');
        await prefs.setString('user_role', rol);

        debugPrint('LOGIN EXITOSO -> Usuario: $nombre ($email), Rol detectado: $rol');

        _mostrarNotificacion('¡Inicio de sesión exitoso! Bienvenido $nombre');

        if (mounted) {
          // Redirigir según el rol
          if (rol == 'admin' || rol == 'administrador') {
            Navigator.pushNamedAndRemoveUntil(context, '/dashboard_admin', (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          }
        }
      }
    } on AuthException catch (e) {
      debugPrint("ERROR DE AUTENTICACIÓN SUPABASE: ${e.message}");
      String mensajeError = e.message;
      final lower = e.message.toLowerCase();
      if (lower.contains('invalid login credentials') || lower.contains('invalid credentials')) {
        mensajeError = 'Correo o contraseña incorrectos. Verifica tus datos.';
      } else if (lower.contains('email not confirmed')) {
        mensajeError = 'El correo aún no ha sido confirmado. Revisa tu bandeja de entrada.';
      }
      _mostrarNotificacion(mensajeError, esError: true);
    } catch (e) {
      debugPrint("ERROR DE SUPABASE: $e");
      _mostrarNotificacion('Error al iniciar sesión: $e', esError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- LÓGICA DE RECUPERAR CONTRASEÑA ---
  Future<void> _ejecutarRecuperarPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _mostrarNotificacion('Por favor ingresa tu correo electrónico', esError: true);
      return;
    }

    if (!_esEmailValido(email)) {
      _mostrarNotificacion('Por favor ingresa un correo electrónico válido', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
      _mostrarNotificacion('Enlace enviado. Revisa tu correo o carpeta de spam.');
      if (mounted) {
        setState(() => _vistaActual = 0);
      }
    } on AuthException catch (e) {
      debugPrint("ERROR AL ENVIAR CORREO DE RECUPERACIÓN: ${e.message}");
      _mostrarNotificacion(e.message, esError: true);
    } catch (e) {
      debugPrint("ERROR INESPERADO: $e");
      _mostrarNotificacion('Error al procesar la solicitud de recuperación', esError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}