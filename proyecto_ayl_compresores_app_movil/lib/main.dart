import 'package:flutter/material.dart';

void main() => runApp(const AYLApp());

class AYLApp extends StatelessWidget {
  const AYLApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'A&L Compresores y Partes',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        primaryColor: const Color(0xFFF5A623),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5A623),
          primary: const Color(0xFFF5A623),
        ),
      ),
      home: const PasarelaPagoScreen(),
    );
  }
}

class PasarelaPagoScreen extends StatefulWidget {
  const PasarelaPagoScreen({super.key});

  @override
  State<PasarelaPagoScreen> createState() => _PasarelaPagoScreenState();
}

class _PasarelaPagoScreenState extends State<PasarelaPagoScreen> {
  int paso = 1;
  String metodoSeleccionado = 'tarjeta';

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _cedulaController = TextEditingController();
  final _direccionController = TextEditingController();
  final _ciudadController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _correoController = TextEditingController();

  String numeroPedido = '';

  @override
  void dispose() {
    _nombreController.dispose();
    _cedulaController.dispose();
    _direccionController.dispose();
    _ciudadController.dispose();
    _telefonoController.dispose();
    _correoController.dispose();
    super.dispose();
  }

  void _avanzarAPago() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        paso = 2;
      });
    }
  }

  void _procesarPago() {
    setState(() {
      numeroPedido = 'AYL-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      paso = 3;
    });
  }

  void _reiniciarFlujo() {
    setState(() {
      paso = 1;
      _nombreController.clear();
      _cedulaController.clear();
      _direccionController.clear();
      _ciudadController.clear();
      _telefonoController.clear();
      _correoController.clear();
      metodoSeleccionado = 'tarjeta';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset(
              'assets/logo-ayl.jpeg',
              height: 32,
              errorBuilder: (context, error, stackTrace) => Row(
                children: const [
                  Text('A & L', style: TextStyle(color: Color(0xFF10142D), fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  CircleAvatar(radius: 4, backgroundColor: Color(0xFFF5A623)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Color(0xFF10142D)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paso == 1) _vistaDatosEnvio(),
            if (paso == 2) _vistaMetodoPago(),
            if (paso == 3) _vistaExito(),
          ],
        ),
      ),
    );
  }

  Widget _vistaDatosEnvio() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Datos de Envío y Facturación', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
          const SizedBox(height: 4),
          const Text('Paso 1 de 2: Información de contacto y entrega industrial', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFEAEAEA)),
            ),
            child: Column(
              children: [
                _inputCampo('NOMBRE Y APELLIDO / RAZÓN SOCIAL', 'Ej. Inversiones Mecánicas S.A.S.', _nombreController),
                _inputCampo('CÉDULA O NIT', 'Ej. 900.123.456-7', _cedulaController),
                _inputCampo('DIRECCIÓN DE ENTREGA', 'Ej. Carrera 68 # 20-30', _direccionController),
                _inputCampo('CIUDAD / MUNICIPIO', 'Ej. Bogotá D.C.', _ciudadController),
                _inputCampo('TELÉFONO DE CONTACTO', 'Ej. 3001234567', _telefonoController, esTelefono: true),
                _inputCampo('CORREO ELECTRÓNICO', 'facturacion@empresa.com', _correoController, esCorreo: true),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5A623),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: _avanzarAPago,
                    child: const Text('Continuar al Pago →', style: TextStyle(color: Color(0xFF10142D), fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputCampo(String etiqueta, String placeholder, TextEditingController controller, {bool esTelefono = false, bool esCorreo = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(etiqueta, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF6C757D))),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: esTelefono ? TextInputType.phone : (esCorreo ? TextInputType.emailAddress : TextInputType.text),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Este campo es obligatorio para procesar el pedido';
              }
              if (esCorreo && !value.contains('@')) {
                return 'Ingrese un correo electrónico válido';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: Colors.black38, fontSize: 13),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFEAEAEA))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Color(0xFFF5A623), width: 1.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vistaMetodoPago() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paso 1 > Paso 2: Método de Pago', style: TextStyle(fontSize: 12, color: Color(0xFF6C757D))),
        const SizedBox(height: 6),
        const Text('Selecciona tu Método de Pago', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 14),
        _opcionPago('tarjeta', 'Tarjetas de Crédito / Débito', 'Visa, MasterCard', Icons.credit_card),
        _opcionPago('billetera', 'Billeteras Digitales', 'Nequi / Daviplata', Icons.phone_android),
        _opcionPago('pse', 'PSE', 'Pagos Seguros en Línea (Bancos)', Icons.account_balance),
        _opcionPago('transferencia', 'Transferencia Bancaria', 'Cuenta Corriente Bancolombia', Icons.domain),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerLeft, child: Text('Resumen de Compra - AyL Compresores', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF10142D)))),
              const Divider(),
              _filaResumen('Compresor Industrial / Kit', '\$750.000 COP'),
              _filaResumen('Envío y Logística', '\$20.000 COP'),
              _filaResumen('IVA (19%)', '\$120.000 COP'),
              const Divider(),
              _filaResumen('Total a pagar', '\$890.000 COP', esTotal: true),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF0F2F5), borderRadius: BorderRadius.circular(6)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.lock_outline, size: 14, color: Color(0xFF6C757D)),
                    SizedBox(width: 6),
                    Text('Pasarela segura cifrada de extremo a extremo', style: TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF5A623),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: _procesarPago,
                  child: const Text('Pagar \$890.000 COP →', style: TextStyle(color: Color(0xFF10142D), fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => paso = 1),
                child: const Text('Regresar a Datos de Envío', style: TextStyle(color: Color(0xFF6C757D))),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _opcionPago(String valor, String titulo, String sub, IconData icono) {
    bool activo = metodoSeleccionado == valor;
    return GestureDetector(
      onTap: () => setState(() => metodoSeleccionado = valor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: activo ? const Color(0xFFF5A623) : const Color(0xFFEAEAEA), width: activo ? 2 : 1),
        ),
        child: Row(
          children: [
            Checkbox(
              value: activo,
              activeColor: const Color(0xFFF5A623),
              shape: const CircleBorder(),
              onChanged: (v) => setState(() => metodoSeleccionado = valor),
            ),
            Icon(icono, color: const Color(0xFF10142D), size: 20),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1A1A1A))),
                Text(sub, style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D))),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _filaResumen(String label, String val, {bool esTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: esTotal ? const Color(0xFF10142D) : const Color(0xFF6C757D), fontWeight: esTotal ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
          Text(val, style: TextStyle(color: esTotal ? const Color(0xFF10142D) : const Color(0xFF1A1A1A), fontWeight: esTotal ? FontWeight.bold : FontWeight.normal, fontSize: esTotal ? 15 : 13)),
        ],
      ),
    );
  }

  Widget _vistaExito() {
    return Column(
      children: [
        const SizedBox(height: 20),
        Container(
          width: 70,
          height: 70,
          decoration: const BoxDecoration(color: Color(0xFF43A047), shape: BoxShape.circle),
          child: const Icon(Icons.check, color: Colors.white, size: 40),
        ),
        const SizedBox(height: 16),
        const Text('¡Transacción Exitosa!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 4),
        const Text('Su pedido ha sido registrado en el sistema de inventario.', style: TextStyle(color: Color(0xFF6C757D), fontSize: 13)),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFEAEAEA)),
          ),
          child: Column(
            children: [
              _filaResumen('Número de Pedido', numeroPedido),
              _filaResumen('Cliente / Empresa', _nombreController.text.isNotEmpty ? _nombreController.text : 'Cliente General'),
              _filaResumen('Método de Pago', metodoSeleccionado.toUpperCase()),
              _filaResumen('Total Cancelado', '\$890.000 COP', esTotal: true),
              const Divider(),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'DESTINO DE ENTREGA:\n${_direccionController.text}, ${_ciudadController.text}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF6C757D)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF5A623),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: () {},
            child: const Text('Generar Comprobante de Venta', style: TextStyle(color: Color(0xFF10142D), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEAEAEA)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            onPressed: _reiniciarFlujo,
            child: const Text('Realizar Nueva Compra', style: TextStyle(color: Color(0xFF1A1A1A), fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      ],
    );
  }
}