import '../empleado/empleado_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/user/auth_helper.dart';
import '../../services/user/usuario_service.dart';
import '../../services/products/cart_service.dart';
import '../productos/productos_screen.dart';
import 'recuperar_password_screen.dart';
import 'cambiar_password_screen.dart';
import '../../services/products/favoritos_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); 
  final _confirmPasswordController = TextEditingController(); 

  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;
  bool _isLoading = false;
  int _vistaActual = 0; // 0 = Login, 1 = Registro

  int _totalOrdenes = 0;
  double _totalGastado = 0.0;
  bool _cargandoEstadisticas = true;

  // Instancias para Biometría y Almacenamiento Seguro
  final LocalAuthentication _authBiometricos = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @override
  void initState() {
    super.initState();
    _cargarDatosEstadisticos();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosEstadisticos() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _cargandoEstadisticas = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('orden')
          .select('total')
          .eq('usuario_id', user.id);

      if (response.isNotEmpty) {
        final listaOrdenes = response as List;
        int cantidad = listaOrdenes.length;
        double sumaTotal = 0.0;

        for (var orden in listaOrdenes) {
          final totalVal = orden['total'];
          if (totalVal != null) {
            sumaTotal += double.tryParse(totalVal.toString()) ?? 0.0;
          }
        }

        if (mounted) {
          setState(() {
            _totalOrdenes = cantidad;
            _totalGastado = sumaTotal;
            _cargandoEstadisticas = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error al cargar órdenes: $e');
      if (mounted) setState(() => _cargandoEstadisticas = false);
    }
  }

  void _mostrarNotificacion(String mensaje, {bool esError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(esError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensaje, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500))),
          ],
        ),
        backgroundColor: esError ? Colors.red.shade800 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<bool> _biometriaDisponible() async {
    try {
      final bool puedeAutenticar = await _authBiometricos.canCheckBiometrics;
      final bool soportado = await _authBiometricos.isDeviceSupported();
      return puedeAutenticar && soportado;
    } catch (_) {
      return false;
    }
  }

  Future<void> _guardarCredencialesBiometricas(String email, String password) async {
    await _secureStorage.write(key: 'saved_email', value: email.trim());
    await _secureStorage.write(key: 'saved_password', value: password);
  }

  Future<void> _limpiarCredencialesBiometricas() async {
    await _secureStorage.delete(key: 'saved_email');
    await _secureStorage.delete(key: 'saved_password');
  }

  Future<void> _iniciarSesionConBiometria() async {
    try {
      final bool disponible = await _biometriaDisponible();
      if (!disponible) {
        _mostrarNotificacion('La biometría no está disponible en este dispositivo.', esError: true);
        return;
      }

      final bool autenticado = await _authBiometricos.authenticate(
        localizedReason: 'Usa tu huella o Face ID para iniciar sesión',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!autenticado) {
        _mostrarNotificacion('Autenticación cancelada.', esError: true);
        return;
      }

      final emailGuardado = await _secureStorage.read(key: 'saved_email');
      final passwordGuardada = await _secureStorage.read(key: 'saved_password');

      if (emailGuardado == null || emailGuardado.isEmpty || passwordGuardada == null || passwordGuardada.isEmpty) {
        _mostrarNotificacion('No hay sesión previa guardada. Inicia sesión con contraseña al menos una vez.', esError: true);
        return;
      }

      setState(() => _isLoading = true);

      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: emailGuardado,
        password: passwordGuardada,
      );

      if (response.user == null) {
        _mostrarNotificacion('No se pudo completar la autenticación biométrica.', esError: true);
        return;
      }

      await AuthHelper.asegurarRegistroUsuario(response.user!);

      final prefs = await SharedPreferences.getInstance();
      final token = response.session?.accessToken ?? '';
      final nombre = AuthHelper.obtenerNombre(response.user!);
      final rol = await AuthHelper.obtenerRolUsuario(user: response.user!);

      await prefs.setString('auth_token', token);
      await prefs.setString('user_id', response.user!.id);
      await prefs.setString('user_name', nombre);
      await prefs.setString('user_email', response.user!.email ?? '');
      await prefs.setString('user_role', rol);

      await CartService().cargarCarritoUsuario();
      await FavoritosService().cargarFavoritosUsuario();

      _mostrarNotificacion('¡Bienvenido de nuevo, $nombre!');

      if (mounted) {
      if (rol.toLowerCase() == 'admin') {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard_admin', (route) => false);
      } else if (rol.toLowerCase() == 'empleado') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const EmpleadoDashboard()),
          (route) => false,
        );
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    }
    } catch (e) {
      _mostrarNotificacion('Error en autenticación biométrica: $e', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAFAFC),
        elevation: 0,
        leading: currentUser == null
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87, size: 20),
                onPressed: () {
                  if (_isLoading) return;
                  Navigator.pop(context);
                },
              )
            : null, 
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: currentUser == null 
              ? _construirFlujoAutenticacion() 
              : _construirPanelPerfilEstilizado(currentUser),
        ),
      ),
    );
  }

  Widget _construirPanelPerfilEstilizado(User user) {
    final nombreUsuario = AuthHelper.obtenerNombre(user);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Center(
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF222222), Color(0xFF3A424A)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        nombreUsuario.isNotEmpty ? nombreUsuario[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Color(0xFFFDB913),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check, size: 14, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                nombreUsuario,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F2537),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user.email ?? '',
                style: const TextStyle(
                  fontSize: 13.5,
                  color: Color(0xFF7A837E),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),

        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                title: 'Órdenes Realizadas',
                value: _cargandoEstadisticas ? '...' : '$_totalOrdenes',
                icon: Icons.receipt_long_rounded,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildMetricCard(
                title: 'Inversión Total',
                value: _cargandoEstadisticas ? '...' : '\$${_totalGastado.toStringAsFixed(0)}',
                icon: Icons.payments_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),

        const Text(
          'CONFIGURACIÓN Y ACTIVIDAD',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF9CA3AF),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildModernMenuTile(
                icon: Icons.favorite_rounded,
                iconColor: Colors.redAccent,
                title: 'Mis Equipos Favoritos',
                subtitle: 'Accede a tus productos guardados',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductsScreen(
                        categoriaInicial: 'Favoritos',
                        showBackButton: true,
                      ),
                    ),
                  );
                },
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 64),
              _buildModernMenuTile(
                icon: Icons.shopping_bag_outlined,
                iconColor: const Color(0xFFFDB913),
                title: 'Mis Compras (Historial)',
                subtitle: '$_totalOrdenes pedidos procesados',
                onTap: () {
                  _mostrarNotificacion('Tienes $_totalOrdenes órdenes registradas en el sistema.');
                },
              ),
              Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 64),
              _buildModernMenuTile(
                icon: Icons.lock_reset_rounded,
                iconColor: const Color(0xFF222222),
                title: 'Cambiar Contraseña',
                subtitle: 'Actualiza tus credenciales de acceso',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CambiarPasswordScreen()),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),

        SizedBox(
          height: 52,
          child: TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.05),
              foregroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            onPressed: _isLoading ? null : () async {
              setState(() => _isLoading = true);

              await AuthHelper.cerrarSesion();
              await _limpiarCredencialesBiometricas();

              if (mounted) {
                setState(() => _isLoading = false);
                _mostrarNotificacion('Sesión cerrada correctamente');
              }
            },
            icon: _isLoading 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.redAccent))
                : const Icon(Icons.logout_rounded, size: 20),
            label: const Text(
              'CERRAR SESIÓN',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.8),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMetricCard({required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Color(0xFF7A837E), fontSize: 11.5, fontWeight: FontWeight.w700),
              ),
              Icon(icon, color: const Color(0xFFFDB913), size: 18),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Color(0xFF0F2537), fontSize: 20, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuTile({
    required IconData icon, 
    required Color iconColor, 
    required String title, 
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: Color(0xFF0F2537)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11.5, color: Color(0xFF7A837E)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF9CA3AF), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirFlujoAutenticacion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _vistaActual == 0 ? '¡Hola de nuevo!' : 'Únete a nosotros',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Color(0xFF0F2537)),
        ),
        const SizedBox(height: 5),
        Text(
          _vistaActual == 1 ? 'Crea tu cuenta para gestionar tus compras' : 'Gestiona tus pedidos industriales',
          style: const TextStyle(color: Color(0xFF7A837E), fontSize: 14),
        ),
        const SizedBox(height: 30),
        Row(
          children: [
            Expanded(child: _construirBotonPestana('INGRESAR', 0)),
            Expanded(child: _construirBotonPestana('REGISTRARSE', 1)),
          ],
        ),
        const Divider(height: 30, thickness: 1),
        if (_vistaActual == 0) _construirFormularioLogin(),
        if (_vistaActual == 1) _construirFormularioRegistro(),
      ],
    );
  }

  Widget _construirBotonPestana(String texto, int indice) {
    bool activo = _vistaActual == indice;
    return GestureDetector(
      onTap: () {
        if (_isLoading) return;
        setState(() {
          _vistaActual = indice;
          _passwordController.clear();
          _confirmPasswordController.clear();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: activo ? const Color(0xFFFDB913) : Colors.transparent, width: 2.5)),
        ),
        child: Text(
          texto,
          textAlign: TextAlign.center,
          style: TextStyle(color: activo ? const Color(0xFF222222) : Colors.grey, fontWeight: FontWeight.w800, fontSize: 13),
        ),
      ),
    );
  }

  Widget _construirFormularioLogin() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(controller: _emailController, hint: 'Correo Electrónico', icono: Icons.email_outlined),
        const SizedBox(height: 15),
        _construirCampoTexto(controller: _passwordController, hint: 'Contraseña', esPassword: true, ocultar: _ocultarPassword, onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword)),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _isLoading ? null : () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RecuperarPasswordScreen()),
              );
            },
            child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Color(0xFFE59819), fontWeight: FontWeight.w700)),
          ),
        ),
        const SizedBox(height: 20),
        _construirBotonPrincipal('INICIAR SESIÓN', _ejecutarLogin),
        const SizedBox(height: 15),
        FutureBuilder<bool>(
          future: _biometriaDisponible(),
          builder: (context, snapshot) {
            final disponible = snapshot.data ?? false;
            if (!disponible) {
              return const SizedBox.shrink();
            }

            return OutlinedButton.icon(
              onPressed: _isLoading ? null : _iniciarSesionConBiometria,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                side: BorderSide(color: Colors.grey.shade300, width: 1.5),
              ),
              icon: const Icon(Icons.fingerprint_rounded, color: Color(0xFF222222)),
              label: const Text(
                'Entrar con Huella / Face ID',
                style: TextStyle(color: Color(0xFF222222), fontWeight: FontWeight.w800, fontSize: 13),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _construirFormularioRegistro() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _construirCampoTexto(controller: _nameController, hint: 'Nombre completo', icono: Icons.person_outline),
        const SizedBox(height: 15),
        _construirCampoTexto(controller: _emailController, hint: 'Correo Electrónico', icono: Icons.email_outlined),
        const SizedBox(height: 15),
        _construirCampoTexto(controller: _passwordController, hint: 'Contraseña (mínimo 6 caracteres)', esPassword: true, ocultar: _ocultarPassword, onTapOjo: () => setState(() => _ocultarPassword = !_ocultarPassword)),
        const SizedBox(height: 15),
        _construirCampoTexto(controller: _confirmPasswordController, hint: 'Confirmar Contraseña', esPassword: true, ocultar: _ocultarConfirmPassword, onTapOjo: () => setState(() => _ocultarConfirmPassword = !_ocultarConfirmPassword)),
        const SizedBox(height: 25),
        _construirBotonPrincipal('CREAR CUENTA GRATIS', _ejecutarRegistro),
      ],
    );
  }

  Widget _construirCampoTexto({required TextEditingController controller, required String hint, bool esPassword = false, bool ocultar = false, VoidCallback? onTapOjo, IconData? icono}) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        prefixIcon: icono != null ? Icon(icono, color: Colors.grey, size: 20) : null,
        suffixIcon: esPassword ? IconButton(icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility, color: Colors.grey), onPressed: onTapOjo) : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5)),
      ),
    );
  }

  Widget _construirBotonPrincipal(String texto, VoidCallback accion) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF222222),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onPressed: _isLoading ? null : accion,
        child: _isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
            : Text(texto, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
      ),
    );
  }

  Future<void> _ejecutarRegistro() async {
    final nombre = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (nombre.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _mostrarNotificacion('Por favor completa todos los campos', esError: true);
      return;
    }
    if (password != confirmPassword) {
      _mostrarNotificacion('Las contraseñas no coinciden', esError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {'nombre': nombre, 'rol': 'cliente'},
      );

      if (response.user != null) {
        await UsuarioService.registrarUsuarioEnBaseDeDatos(id: response.user!.id, nombre: nombre, correo: email, rol: 'cliente');

        await _guardarCredencialesBiometricas(email, password);

        _mostrarNotificacion('¡Cuenta creada con éxito!');
        setState(() {});
      }
    } catch (e) {
      _mostrarNotificacion('Error en el registro: $e', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _ejecutarLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _mostrarNotificacion('Llena todos los campos', esError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email, 
        password: password,
      );
      
      if (response.user != null) {
        await AuthHelper.asegurarRegistroUsuario(response.user!);

        await _guardarCredencialesBiometricas(email, password);

        final prefs = await SharedPreferences.getInstance();
        final token = response.session?.accessToken ?? '';
        final nombre = AuthHelper.obtenerNombre(response.user!);
        final rol = await AuthHelper.obtenerRolUsuario(user: response.user!);

        await prefs.setString('auth_token', token);
        await prefs.setString('user_id', response.user!.id);
        await prefs.setString('user_name', nombre);
        await prefs.setString('user_email', response.user!.email ?? '');
        await prefs.setString('user_role', rol);

        await CartService().cargarCarritoUsuario();
        await FavoritosService().cargarFavoritosUsuario();

        _mostrarNotificacion('¡Bienvenido $nombre!');

        if (mounted) {
        if (rol.toLowerCase() == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/dashboard_admin',
            (route) => false,
          );
        } else if (rol.toLowerCase() == 'empleado') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const EmpleadoDashboard()),
            (route) => false,
          );
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      }
      }
    } catch (e) {
      _mostrarNotificacion('Correo o contraseña incorrectos', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}