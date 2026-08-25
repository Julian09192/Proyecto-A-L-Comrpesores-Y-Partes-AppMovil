import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/products/producto_model.dart';

class ProductoService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. getAll - Obtener todos los productos no suspendidos o todos
  Future<List<ProductoModel>> getAll({bool soloActivos = true}) async {
    try {
      var query = _supabase.from('productos').select('*');
      
      if (soloActivos) {
        query = query.eq('suspendido', false);
      }

      final data = await query.order('id', ascending: false);
      return (data as List).map((json) => ProductoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error en getAll: $e');
      rethrow;
    }
  }

  // 2. getById - Obtener producto por ID
  Future<ProductoModel?> getById(dynamic id) async {
    try {
      final data = await _supabase
          .from('productos')
          .select('*')
          .eq('id', id)
          .maybeSingle();

      if (data == null) return null;
      return ProductoModel.fromJson(data);
    } catch (e) {
      debugPrint('Error en getById: $e');
      rethrow;
    }
  }

  // 3. getStock - Obtener datos de stock de un producto
  Future<Map<String, dynamic>?> getStock(dynamic id) async {
    try {
      final data = await _supabase
          .from('productos')
          .select('nombre, stock_total, marca')
          .eq('id', id)
          .maybeSingle();

      return data;
    } catch (e) {
      debugPrint('Error en getStock: $e');
      rethrow;
    }
  }

  // 4. filterByParams - Filtrar por bodega, marca, tipo o código interno
  Future<List<ProductoModel>> filterByParams({
    int? idBodega,
    String? marca,
    String? tipo,
    String? codigoInterno,
    String? searchQuery,
  }) async {
    try {
      var query = _supabase.from('productos').select('*');

      if (idBodega != null) {
        query = query.eq('bodega_id', idBodega);
      }
      if (marca != null && marca.isNotEmpty) {
        query = query.eq('marca', marca);
      }
      if (tipo != null && tipo.isNotEmpty && tipo != 'Todos') {
        query = query.ilike('tipo', '%$tipo%');
      }
      if (codigoInterno != null && codigoInterno.isNotEmpty) {
        query = query.eq('codigo_interno', codigoInterno);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('nombre', '%$searchQuery%');
      }

      final data = await query.order('id', ascending: false);
      return (data as List).map((json) => ProductoModel.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error en filterByParams: $e');
      rethrow;
    }
  }

  // 5. crear - Crear nuevo producto
  Future<ProductoModel> crear({
    required String nombre,
    String? descripcion,
    required double precio,
    int stock = 0,
    String? idCategoria, // Usado para el campo 'tipo'
    int? idBodega,
    String? imagenUrl,
    String? imagenPublicId,
    String? marca,
    String? codigoInterno,
  }) async {
    try {
      final nuevoProducto = {
        'nombre': nombre,
        'caracteristicas': descripcion ?? '',
        'precio': precio,
        'stock_total': stock,
        'tipo': idCategoria ?? 'Aceite',
        'bodega_id': idBodega,
        'marca': marca ?? 'Generico',
        'codigo_interno': codigoInterno,
        'imagen_url': imagenUrl,
        'cloudinary_imagen_public_id': imagenPublicId,
        'suspendido': false,
      };

      final data = await _supabase
          .from('productos')
          .insert(nuevoProducto)
          .select()
          .single();

      return ProductoModel.fromJson(data);
    } catch (e) {
      debugPrint('Error en crear: $e');
      rethrow;
    }
  }

  // 6. update - Actualizar datos de un producto
  Future<ProductoModel> update(dynamic id, Map<String, dynamic> updates) async {
    try {
      final dataToUpdate = Map<String, dynamic>.from(updates);

      // Normalizaciones del frontend al modelo de la BD
      if (updates.containsKey('stock')) {
        dataToUpdate['stock_total'] = updates['stock'];
        dataToUpdate.remove('stock');
      }
      if (updates.containsKey('id_bodega')) {
        dataToUpdate['bodega_id'] = updates['id_bodega'];
        dataToUpdate.remove('id_bodega');
      }
      if (updates.containsKey('imagen_public_id')) {
        dataToUpdate['cloudinary_imagen_public_id'] = updates['imagen_public_id'];
        dataToUpdate.remove('imagen_public_id');
      }

      final data = await _supabase
          .from('productos')
          .update(dataToUpdate)
          .eq('id', id)
          .select()
          .single();

      return ProductoModel.fromJson(data);
    } catch (e) {
      debugPrint('Error en update: $e');
      rethrow;
    }
  }

  // 7. toggleSuspension - Alternar suspensión de producto
  Future<ProductoModel> toggleSuspension(dynamic id) async {
    try {
      // 1. Obtener estado actual
      final current = await _supabase
          .from('productos')
          .select('suspendido')
          .eq('id', id)
          .single();

      final nuevoEstado = !(current['suspendido'] as bool? ?? false);

      // 2. Actualizar al estado inverso
      final data = await _supabase
          .from('productos')
          .update({'suspendido': nuevoEstado})
          .eq('id', id)
          .select()
          .single();

      return ProductoModel.fromJson(data);
    } catch (e) {
      debugPrint('Error en toggleSuspension: $e');
      rethrow;
    }
  }
}