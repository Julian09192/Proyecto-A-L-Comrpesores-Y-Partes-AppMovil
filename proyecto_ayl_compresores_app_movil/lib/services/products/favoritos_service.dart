import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosService {
  final _supabase = Supabase.instance.client;

  // 1. Verifica si el usuario actual tiene rol 'cliente'
  Future<bool> _esClienteValido() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      print('DEBUG: No hay usuario logueado.');
      return false;
    }

    try {
      print('DEBUG: Buscando rol para el correo -> ${user.email}');
      
      // 🚀 CORRECCIÓN APLICADA: 'usuario' sin la 's' final
      final data = await _supabase
          .from('usuario')
          .select('rol')
          .eq('correo', user.email!)
          .maybeSingle();
          
      print('DEBUG: Respuesta de la tabla usuario -> $data');

      // Si data es null, significa que no existe en tu tabla o RLS lo bloquea
      if (data == null) {
        print('DEBUG: No se encontró el correo en la tabla o hubo un error.');
        return false;
      }

      // Limpiamos espacios y pasamos a minúsculas
      final rol = data['rol'].toString().trim().toLowerCase();
      print('DEBUG: Rol detectado -> $rol');
      
      return rol == 'cliente';
    } catch (e) {
      print('DEBUG: Error de Supabase al buscar el rol -> $e');
      return false;
    }
  }

  Future<List<int>> obtenerIdsFavoritos() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      final data = await _supabase
          .from('favoritos')
          .select('producto_id')
          .eq('usuario_id', user.id);
          
      return (data as List).map((item) => item['producto_id'] as int).toList();
    } catch (e) {
      print('DEBUG: Error al obtener IDs de favoritos -> $e');
      return [];
    }
  }

  // 2. Consulta si un producto ya está en favoritos
  Future<bool> esFavorito(int productoId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return false;

    try {
      final data = await _supabase
          .from('favoritos')
          .select('id')
          .eq('usuario_id', user.id)
          .eq('producto_id', productoId)
          .maybeSingle();
          
      return data != null;
    } catch (e) {
      return false;
    }
  }

  // 3. Agrega o quita el favorito si cumple los requisitos
  Future<bool> toggleFavorito(int productoId) async {
    final user = _supabase.auth.currentUser;
    
    // Si no está logueado, lanzamos una excepción para que la UI muestre el aviso
    if (user == null) throw Exception('no_auth');

    // Validamos el rol
    final esCliente = await _esClienteValido();
    if (!esCliente) throw Exception('no_cliente');

    // Revisamos si ya es favorito
    final existe = await esFavorito(productoId);

    if (existe) {
      // Si ya existe, lo eliminamos (Quitar like)
      await _supabase
          .from('favoritos')
          .delete()
          .eq('usuario_id', user.id)
          .eq('producto_id', productoId);
      return false;
    } else {
      // Si no existe, lo insertamos (Dar like)
      await _supabase.from('favoritos').insert({
        'usuario_id': user.id,
        'producto_id': productoId,
      });
      return true;
    }
  }
}