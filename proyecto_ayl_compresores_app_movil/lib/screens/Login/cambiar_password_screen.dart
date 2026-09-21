import 'package:flutter/material.dart';
import '../../services/user/cambiar_password_service.dart';

class CambiarPasswordScreen extends StatefulWidget {
  const CambiarPasswordScreen({super.key});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _passActualController = TextEditingController();
  final _nuevoPassController = TextEditingController();
  final _confirmarPassController = TextEditingController();

  bool _ocultarActual = true;
  bool _ocultarNuevo = true;
  bool _ocultarConfirmar = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passActualController.dispose();
    _nuevoPassController.dispose();
    _confirmarPassController.dispose();
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
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _ejecutarCambioPassword() async {
    final actual = _passActualController.text;
    final nuevo = _nuevoPassController.text;
    final confirmar = _confirmarPassController.text;

    if (actual.isEmpty || nuevo.isEmpty || confirmar.isEmpty) {
      _mostrarNotificacion('Por favor completa todos los campos.', esError: true);
      return;
    }

    if (nuevo.length < 6) {
      _mostrarNotificacion('La nueva contraseña debe tener al menos 6 caracteres.', esError: true);
      return;
    }

    if (nuevo != confirmar) {
      _mostrarNotificacion('Las nuevas contraseñas no coinciden.', esError: true);
      return;
    }

    if (actual == nuevo) {
      _mostrarNotificacion('La nueva contraseña no puede ser igual a la actual.', esError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await CambiarPasswordService.cambiarPassword(
        passwordActual: actual,
        nuevoPassword: nuevo,
      );

      _mostrarNotificacion('¡Contraseña actualizada con éxito!');
      if (mounted) {
        Navigator.pop(context); // Regresa al perfil
      }
    } catch (e) {
      final mensajeLimpio = e.toString().replaceAll("Exception: ", "");
      _mostrarNotificacion(mensajeLimpio, esError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cambiar Contraseña',
          style: TextStyle(color: Color(0xFF0F2537), fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Actualiza tu seguridad',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F2537)),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ingresa tu contraseña actual y la nueva clave que deseas utilizar.',
                style: TextStyle(fontSize: 13.5, color: Color(0xFF7A837E)),
              ),
              const SizedBox(height: 30),

              // Contraseña Actual
              _construirCampoTexto(
                controller: _passActualController,
                hint: 'Contraseña actual',
                ocultar: _ocultarActual,
                onTapOjo: () => setState(() => _ocultarActual = !_ocultarActual),
              ),
              const SizedBox(height: 16),

              // Nueva Contraseña
              _construirCampoTexto(
                controller: _nuevoPassController,
                hint: 'Nueva contraseña (mínimo 6 caracteres)',
                ocultar: _ocultarNuevo,
                onTapOjo: () => setState(() => _ocultarNuevo = !_ocultarNuevo),
              ),
              const SizedBox(height: 16),

              // Confirmar Nueva Contraseña
              _construirCampoTexto(
                controller: _confirmarPassController,
                hint: 'Confirmar nueva contraseña',
                ocultar: _ocultarConfirmar,
                onTapOjo: () => setState(() => _ocultarConfirmar = !_ocultarConfirmar),
              ),
              const SizedBox(height: 35),

              // Botón Guardar Cambios
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF222222),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _isLoading ? null : _ejecutarCambioPassword,
                  child: _isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ACTUALIZAR CONTRASEÑA', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _construirCampoTexto({
    required TextEditingController controller,
    required String hint,
    required bool ocultar,
    required VoidCallback onTapOjo,
  }) {
    return TextField(
      controller: controller,
      obscureText: ocultar,
      enabled: !_isLoading,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: const Icon(Icons.lock_outline_rounded, color: Colors.grey, size: 20),
        suffixIcon: IconButton(
          icon: Icon(ocultar ? Icons.visibility_off : Icons.visibility, color: Colors.grey, size: 20),
          onPressed: onTapOjo,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.shade200, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF222222), width: 1.5)),
      ),
    );
  }
}