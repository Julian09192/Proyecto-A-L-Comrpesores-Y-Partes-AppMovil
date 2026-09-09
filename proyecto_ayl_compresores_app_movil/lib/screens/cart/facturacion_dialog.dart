import 'package:flutter/material.dart';
import '../../services/siigo/siigo_service.dart';

class FacturacionDialog extends StatefulWidget {
  final List<dynamic> itemsCarrito;
  final double totalPagar;

  const FacturacionDialog({
    super.key,
    required this.itemsCarrito,
    required this.totalPagar,
  });

  @override
  State<FacturacionDialog> createState() => _FacturacionDialogState();
}

class _FacturacionDialogState extends State<FacturacionDialog> {
  final _formKey = GlobalKey<FormState>();
  final SiigoService _siigoService = SiigoService();

  final TextEditingController _cedulaController = TextEditingController();
  final TextEditingController _nombresController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  bool _isLoading = false;
  static const Color primaryColor = Color(0xFFF5A623);

  @override
  void dispose() {
    _cedulaController.dispose();
    _nombresController.dispose();
    _apellidosController.dispose();
    _correoController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  InputDecoration _customInputDecoration({
    required String labelText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.grey[700], size: 20),
      filled: true,
      fillColor: Colors.grey[100],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
    );
  }

  Future<void> _procesarFactura() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final datosCliente = {
        'identification': _cedulaController.text.trim(),
        'name': [
          _nombresController.text.trim(),
          _apellidosController.text.trim(),
        ],
        'email': _correoController.text.trim(),
        'phone': _telefonoController.text.trim(),
        'address': _direccionController.text.trim(),
      };

      // Envío de datos a la API de Siigo
      final exito = await _siigoService.generarFacturaDian(
        cliente: datosCliente,
        items: widget.itemsCarrito,
        total: widget.totalPagar,
      );

      if (!mounted) return;

      if (exito) {
        Navigator.of(context).pop(true); // Cierra el modal y notifica éxito
      } else {
        _mostrarSnackBar('No se pudo procesar la factura en Siigo', Colors.red);
      }
    } catch (e) {
      if (!mounted) return;
      _mostrarSnackBar('Error de conexión con Siigo: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _mostrarSnackBar(String mensaje, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 450),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Encabezado
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      color: primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Datos de Facturación DIAN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF212529),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      icon: const Icon(Icons.close, color: Colors.grey),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Campos del Formulario
                TextFormField(
                  controller: _cedulaController,
                  keyboardType: TextInputType.number,
                  decoration: _customInputDecoration(
                    labelText: 'Cédula / NIT',
                    icon: Icons.badge_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _nombresController,
                  decoration: _customInputDecoration(
                    labelText: 'Nombres',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _apellidosController,
                  decoration: _customInputDecoration(
                    labelText: 'Apellidos',
                    icon: Icons.person_outline,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _correoController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _customInputDecoration(
                    labelText: 'Correo recepción DIAN',
                    icon: Icons.email_outlined,
                  ),
                  validator: (value) => value == null || !value.contains('@')
                      ? 'Ingrese un correo válido'
                      : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _direccionController,
                  decoration: _customInputDecoration(
                    labelText: 'Dirección',
                    icon: Icons.location_on_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _telefonoController,
                  keyboardType: TextInputType.phone,
                  decoration: _customInputDecoration(
                    labelText: 'Teléfono',
                    icon: Icons.phone_outlined,
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 24),

                // Botones de acción con estado de carga
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _procesarFactura,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Confirmar y Facturar',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
