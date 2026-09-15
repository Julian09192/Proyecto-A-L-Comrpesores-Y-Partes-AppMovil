import 'package:flutter/material.dart';

class ContactoView extends StatefulWidget {
  const ContactoView({super.key});

  @override
  State<ContactoView> createState() => _ContactoViewState();
}

class _ContactoViewState extends State<ContactoView> {
  final _nombreCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _mensajeCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _mensajeCtrl.dispose();
    super.dispose();
  }

  void _enviarMensaje() {
    if (_nombreCtrl.text.trim().isEmpty || _mensajeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa al menos tu nombre y mensaje.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _enviando = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() => _enviando = false);
      _nombreCtrl.clear();
      _correoCtrl.clear();
      _mensajeCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Mensaje enviado con éxito! Nuestro equipo te contactará pronto.'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabecera
            const Text(
              'Canales de Atención',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Text(
              'Estamos disponibles para atender tus solicitudes, cotizaciones y emergencias técnicas.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 20),

            // Tarjetas Rápidas de Contacto
            _canalCard(
              icon: Icons.chat_bubble_rounded,
              colorIcono: const Color(0xFF25D366),
              titulo: 'Línea de WhatsApp',
              subtitulo: '+57 324 345 2243',
              detalle: 'Respuesta inmediata en horario laboral',
            ),
            _canalCard(
              icon: Icons.phone_in_talk_rounded,
              colorIcono: Colors.blue,
              titulo: 'Línea Telefónica',
              subtitulo: '(601) 324 3452',
              detalle: 'Atención a plantas industriales y compras corporativas',
            ),
            _canalCard(
              icon: Icons.email_rounded,
              colorIcono: Colors.amber.shade800,
              titulo: 'Correo Electrónico',
              subtitulo: 'ventas@aylcompresores.com',
              detalle: 'Envío de órdenes de compra y solicitudes DIAN',
            ),
            _canalCard(
              icon: Icons.location_on_rounded,
              colorIcono: Colors.redAccent,
              titulo: 'Sede Principal / Despachos',
              subtitulo: 'Carrera 68 # 20-30, Zona Industrial',
              detalle: 'Bogotá D.C., Colombia',
            ),
            _canalCard(
              icon: Icons.access_time_filled_rounded,
              colorIcono: Colors.teal,
              titulo: 'Horario de Atención',
              subtitulo: 'Lunes a Viernes: 7:30 a.m. - 5:30 p.m.',
              detalle: 'Sábados: 8:00 a.m. - 1:00 p.m.',
            ),

            const SizedBox(height: 24),

            // Formulario de mensaje directo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
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
                  const Text(
                    'Envíanos tu consulta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Déjanos tus requerimientos o número de parte para cotizarte.',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre o Razón Social',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _correoCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Correo de Contacto',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _mensajeCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Mensaje / Referencia requerida',
                      hintText: 'Ej. Requiero cotización de 4 filtros FS-19732 para compresor de tornillo',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: _enviando ? null : _enviarMensaje,
                      child: _enviando
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'ENVIAR MENSAJE',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _canalCard({
    required IconData icon,
    required Color colorIcono,
    required String titulo,
    required String subtitulo,
    required String detalle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colorIcono.withValues(alpha: 0.12),
            child: Icon(icon, color: colorIcono, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detalle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
