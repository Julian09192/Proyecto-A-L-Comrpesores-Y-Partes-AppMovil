import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class ContactoScreen extends StatefulWidget {
  const ContactoScreen({super.key});

  @override
  State<ContactoScreen> createState() => _ContactoScreenState();
}

class _ContactoScreenState extends State<ContactoScreen> {
  // Controladores del formulario
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _asuntoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();

  // Estados
  bool _politicaAceptada = false;
  bool _isSubmitting = false;
  bool _intentoEnviar = false; // Para poner el check en rojo si intentó sin aceptar

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _correoCtrl.dispose();
    _asuntoCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  // --- LÓGICA DE EMAILJS IDÉNTICA A TU REACT ---
  Future<void> _enviarMensaje() async {
    setState(() => _intentoEnviar = true);

    // 1. Validación de Formulario Básico
    if (!_formKey.currentState!.validate()) return;
    
    // 2. Validación de Política de Privacidad (Habeas Data)
    if (!_politicaAceptada) {
      _mostrarAlerta(
        icono: Icons.warning_rounded,
        colorIcono: Colors.orange,
        titulo: 'Acepta la política',
        mensaje: 'Debes aceptar la Política de Privacidad antes de enviar el formulario.',
      );
      return;
    }

    // 3. Evitar doble envío
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    // 4. Modal de "Enviando..." (Equivalente a Swal.showLoading)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(16))),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFFFDB913)),
              SizedBox(height: 16),
              Text('Enviando mensaje...', style: TextStyle(fontSize: 14, decoration: TextDecoration.none, color: Colors.black87, fontWeight: FontWeight.normal)),
            ],
          ),
        ),
      ),
    );

    try {
      // 5. Petición HTTP a la API de EmailJS
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
  'service_id': 'service_i16u9vm', 
  'template_id': 'template_aqqdq5c',
  'user_id': 'sgFOZY5SPPk7ruthI', // Public Key
  'accessToken': 'mxaY3Nl31amiVh6H_c44D', // <-- Añade tu Private Key aquí
  'template_params': {
    'first_name': _nombreCtrl.text.trim(),
    'last_name': _apellidoCtrl.text.trim(),
    'email': _correoCtrl.text.trim(),
    'title': _asuntoCtrl.text.trim(),
    'message': _mensajeCtrl.text.trim(),
  }
}),
      );

      Navigator.pop(context); // Cierra el modal de carga

      if (response.statusCode == 200) {
        // 6. Éxito
        _mostrarAlerta(
          icono: Icons.check_circle_rounded,
          colorIcono: const Color(0xFF4CAF50),
          titulo: '¡Mensaje enviado!',
          mensaje: 'Un asesor técnico se pondrá en contacto contigo pronto.',
        );
        _formKey.currentState!.reset();
        _nombreCtrl.clear();
        _apellidoCtrl.clear();
        _correoCtrl.clear();
        _asuntoCtrl.clear();
        _mensajeCtrl.clear();
        setState(() {
          _politicaAceptada = false;
          _intentoEnviar = false;
        });
      } else {
        throw Exception('Error al enviar email');
      }
    } catch (error) {
      // 7. Error
      Navigator.pop(context); // Cierra el modal en caso de error
      _mostrarAlerta(
        icono: Icons.error_rounded,
        colorIcono: const Color(0xFFD32F2F),
        titulo: 'Error de envío',
        mensaje: 'No pudimos enviar tu mensaje. Por favor intenta por WhatsApp o llama a nuestras líneas de atención.',
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  // --- EQUIVALENTE A SWAL.FIRE EN FLUTTER ---
  void _mostrarAlerta({required IconData icono, required Color colorIcono, required String titulo, required String mensaje}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: colorIcono, size: 60),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF1E242B))),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.black.withValues(alpha: 0.6))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFDB913),
                  foregroundColor: const Color(0xFF141414),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> _lanzarUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        centerTitle: true,
        title: const Text('Contacto', style: TextStyle(color: Color(0xFF10142D), fontWeight: FontWeight.w900, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF10142D)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CANALES DE ATENCIÓN DIRECTA ---
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¿Cómo podemos ayudarte?', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Color(0xFF10142D))),
                  const SizedBox(height: 6),
                  const Text(
                    'Selecciona un canal de atención o usa el formulario para enviarnos tu consulta directamente.',
                    style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  _tarjetaContacto(
                    icono: Icons.chat_bubble_rounded,
                    titulo: 'WhatsApp (Ventas y Soporte)',
                    subtitulo: '+57 311 4405432',
                    colorFondo: const Color(0xFFE8F5E9),
                    colorIcono: const Color(0xFF2E7D32),
                    onTap: () => _lanzarUrl('https://wa.me/573114405432'),
                  ),
                  const SizedBox(height: 12),
                  _tarjetaContacto(
                    icono: Icons.phone_in_talk_rounded,
                    titulo: 'Línea Telefónica',
                    subtitulo: '+57 311 4405432',
                    colorFondo: const Color(0xFFF3E5F5),
                    colorIcono: const Color(0xFF6A1B9A),
                    onTap: () => _lanzarUrl('tel:+573114405432'),
                  ),
                  const SizedBox(height: 12),
                  _tarjetaContacto(
                    icono: Icons.email_rounded,
                    titulo: 'Correo Electrónico',
                    subtitulo: 'contacto@aylcompresores.com',
                    colorFondo: const Color(0xFFE3F2FD),
                    colorIcono: const Color(0xFF1565C0),
                    onTap: () => _lanzarUrl('mailto:contacto@aylcompresores.com'),
                  ),
                ],
              ),
            ),

            // --- FORMULARIO EMAILJS ---
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE0E0E0)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Envíanos un mensaje', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF10142D))),
                    const SizedBox(height: 4),
                    const Text('Completa el formulario y te contactaremos pronto.', style: TextStyle(fontSize: 13, color: Colors.grey)),
                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(child: _construirCampo('Nombre', _nombreCtrl, 'Juan')),
                        const SizedBox(width: 12),
                        Expanded(child: _construirCampo('Apellido', _apellidoCtrl, 'Pérez')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _construirCampo('Correo electrónico', _correoCtrl, 'nombre@empresa.com', tipo: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _construirCampo('Empresa / Asunto', _asuntoCtrl, 'Ej: Cotización Filtros', obligatorio: false),
                    const SizedBox(height: 16),
                    _construirCampo('Mensaje', _mensajeCtrl, 'Cuéntanos qué productos o servicios necesitas...', lineas: 4),
                    const SizedBox(height: 20),

                    // Habeas Data
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 24,
                          height: 24,
                          child: Checkbox(
                            value: _politicaAceptada,
                            activeColor: const Color(0xFFFDB913),
                            // Pinta el borde rojo si intentó enviar sin aceptar
                            side: BorderSide(
                              color: (!_politicaAceptada && _intentoEnviar) ? Colors.red : Colors.grey.shade500,
                              width: 1.5,
                            ),
                            onChanged: _isSubmitting ? null : (val) => setState(() => _politicaAceptada = val!),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: const TextSpan(
                                  style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                                  children: [
                                    TextSpan(text: 'Acepto el uso de mis datos según la Ley 1581 de 2012. Ver '),
                                    TextSpan(text: 'Política de Privacidad', style: TextStyle(color: Color(0xFFFDB913), fontWeight: FontWeight.bold)),
                                    TextSpan(text: '.'),
                                  ],
                                ),
                              ),
                              if (!_politicaAceptada && _intentoEnviar)
                                const Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('Debes aceptar la Política de Privacidad para continuar.', style: TextStyle(color: Colors.red, fontSize: 11)),
                                )
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Botón Enviar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFDB913),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          disabledBackgroundColor: const Color(0xFFFDB913).withValues(alpha: 0.6),
                        ),
                        onPressed: _isSubmitting ? null : _enviarMensaje,
                        child: _isSubmitting
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                                  SizedBox(width: 10),
                                  Text('Enviando...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                                ],
                              )
                            : const Text('Enviar mensaje', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS REUTILIZABLES ---
  Widget _construirCampo(String label, TextEditingController controller, String hint, {int lineas = 1, bool obligatorio = true, TextInputType tipo = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF888888), letterSpacing: 0.5),
            children: [
              TextSpan(text: label.toUpperCase()),
              if (obligatorio) const TextSpan(text: ' *', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: lineas,
          keyboardType: tipo,
          enabled: !_isSubmitting, // Deshabilita el input si está enviando
          validator: obligatorio ? (value) => value!.isEmpty ? 'Requerido' : null : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
            filled: true,
            fillColor: _isSubmitting ? const Color(0xFFF8F9FA) : Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFFDB913), width: 2)),
            disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.5)),
          ),
        ),
      ],
    );
  }

  Widget _tarjetaContacto({required IconData icono, required String titulo, required String subtitulo, required Color colorFondo, required Color colorIcono, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(color: colorFondo, borderRadius: BorderRadius.circular(12)),
              child: Icon(icono, color: colorIcono, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF10142D))),
                  const SizedBox(height: 2),
                  Text(subtitulo, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}