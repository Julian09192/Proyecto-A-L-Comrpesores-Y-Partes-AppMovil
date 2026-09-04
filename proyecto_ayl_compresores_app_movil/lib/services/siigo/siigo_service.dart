import 'dart:convert';
import 'package:http/http.dart' as http;

class SiigoService {
  final String _baseUrl = 'https://api.siigo.com';

  final String _username = 'correo_siigo@ejemplo.com';
  final String _accessKey = 'TU_ACCESS_KEY';
  final String _partnerId = 'AyL_Compresores_App';
  String? _token;

  Future<String?> _obtenerToken() async {
    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/auth'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': _username, 'access_key': _accessKey}),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body)['access_token'];
      }
    } catch (_) {}
    return null;
  }

  Future<bool> generarFacturaDian({
    required Map<String, dynamic> cliente,
    required List<dynamic> items,
    required double total,
  }) async {
    _token ??= await _obtenerToken();
    if (_token == null) return false;

    final nombresDesdeFormulario = cliente['name'];
    final nombres = _texto(
      cliente['nombres'] ??
          (nombresDesdeFormulario is List && nombresDesdeFormulario.isNotEmpty
              ? nombresDesdeFormulario.first
              : nombresDesdeFormulario),
    );
    final apellidos = _texto(
      cliente['apellidos'] ??
          (nombresDesdeFormulario is List && nombresDesdeFormulario.length > 1
              ? nombresDesdeFormulario[1]
              : null),
    );
    final identificacion = _texto(
      cliente['cedula'] ??
          cliente['identificacion'] ??
          cliente['identification'],
    );
    final correo = _texto(cliente['correo'] ?? cliente['email']);
    final telefono = _texto(cliente['telefono'] ?? cliente['phone']);
    final direccion = _texto(cliente['direccion'] ?? cliente['address']);

    final body = {
      'document': {'id': 24416},
      'date': DateTime.now().toIso8601String().split('T')[0],
      'customer': {
        'person_type': 'Person',
        'id_type': '13',
        'identification': identificacion,
        'name': [nombres, apellidos],
        'fiscal_responsibilities': [
          {'code': 'R-99-PN'},
        ],
        'address': {
          'address': direccion,
          'city': {
            'country_code': 'Co',
            'state_code': '11',
            'city_code': '11001',
          },
        },
        'contacts': [
          {
            'first_name': nombres,
            'last_name': apellidos,
            'email': correo,
            'phone': {'number': telefono},
          },
        ],
      },
      'items': items
          .map(
            (item) => {
              'code': item.id ?? '001',
              'description': item.nombre ?? 'Producto',
              'quantity': item.cantidad ?? 1,
              'price': item.precio ?? 0.0,
              'taxes': [
                {'id': 1234},
              ],
            },
          )
          .toList(),
      'payments': [
        {'id': 5678, 'value': total},
      ],
    };

    try {
      final res = await http.post(
        Uri.parse('$_baseUrl/v1/invoices'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
          'Partner-Id': _partnerId,
        },
        body: jsonEncode(body),
      );
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  String _texto(dynamic valor) => valor?.toString() ?? '';
}
