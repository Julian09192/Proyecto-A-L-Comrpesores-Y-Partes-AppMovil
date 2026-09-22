import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/user/auth_helper.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _ocultarPassword = true;
  bool _ocultarConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
      ),
    );
  }

  Future<void> _cancelarYSalir() async {
    if (_isLoading) return;
    // Cerrar cualquier sesión temporal de recuperación para no dejar al usuario en estado inconsistente
    await AuthHelper.cerrarSesion();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  Future<void> _actualizarPassword() async {
    final nuevaPassword = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    
    if (nuevaPassword.isEmpty || confirmPassword.isEmpty) {
      _mostrarNotificacion('Por favor completa todos los campos', esError: true);
      return;
    }

    if (nuevaPassword.length < 6) {
      _mostrarNotificacion('La contraseña debe tener al menos 6 caracteres', esError: true);
      return;
    }

    if (nuevaPassword != confirmPassword) {
      _mostrarNotificacion('Las contraseñas no coinciden', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Guardar el correo actual del usuario para pasarlo al login
      final userEmail = Supabase.instance.client.auth.currentUser?.email ?? '';

      // 2. Guardar la nueva contraseña en Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: nuevaPassword),
      );

      // 3. Cerrar la sesión de recuperación para que NO entre de inmediato, sino que vuelva a llenar el login
      await AuthHelper.cerrarSesion();
      
      // 4. Redirigir al login para que ingrese limpiamente con sus nuevas credenciales
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
          arguments: {
            'email': userEmail,
            'mensajeExito': '¡Contraseña actualizada con éxito! Inicia sesión con tu nueva contraseña.',
          },
        );
      }
    } catch (e) {
      _mostrarNotificacion('Error al actualizar la contraseña: $e', esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _cancelarYSalir();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
            onPressed: _cancelarYSalir,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Caja verde de éxito
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle_outline, size: 50, color: Colors.green),
                      SizedBox(height: 10),
                      Text('¡Enlace verificado!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F2537))),
                      SizedBox(height: 5),
                      Text(
                        'Ingresa tu nueva contraseña para restablecer el acceso a tu cuenta.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF7A837E), fontSize: 13.5, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 35),
                
                // Campo de Nueva Contraseña
                TextField(
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Nueva contraseña (mínimo 6 caracteres)',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                      onPressed: () => setState(() => _ocultarPassword = !_ocultarPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 16),

                // Campo de Confirmar Contraseña
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: _ocultarConfirmPassword,
                  enabled: !_isLoading,
                  decoration: InputDecoration(
                    hintText: 'Confirmar nueva contraseña',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_ocultarConfirmPassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
                      onPressed: () => setState(() => _ocultarConfirmPassword = !_ocultarConfirmPassword),
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5)),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Botón Guardar
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222222),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _isLoading ? null : _actualizarPassword,
                    child: _isLoading
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('GUARDAR CONTRASEÑA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}