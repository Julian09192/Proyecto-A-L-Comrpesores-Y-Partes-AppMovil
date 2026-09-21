import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/products/cart_item_model.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _items = [];
  final SupabaseClient _supabase = Supabase.instance.client;

  int? _idCarritoActivo;

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // ==========================================
  // GESTIÓN DE SESIÓN (LOGIN / LOGOUT)
  // ==========================================

  /// Llama esto justo al iniciar sesión
  Future<void> cargarCarritoUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final idCarrito = await _obtenerOCrearCarritoId(user.id);
      if (idCarrito == null) return;

      _idCarritoActivo = idCarrito;

      // Se especifica la relación concreta para evitar el error PGRST201
      final itemsResponse = await _supabase
          .from('carrito_item')
          .select('id_carrito_item, cantidad, id_producto, precio_unitario, productos!carrito_item_id_producto_fkey(*)')
          .eq('id_carrito', idCarrito);

      _items.clear();

      for (var row in (itemsResponse as List)) {
        final prod = row['productos'];
        if (prod != null) {
          _items.add(
            CartItemModel(
              id: row['id_producto'].toString(),
              nombre: prod['nombre'] ?? '',
              marca: prod['marca'] ?? '',
              precio: (row['precio_unitario'] as num?)?.toDouble() ?? 
                      (prod['precio'] as num?)?.toDouble() ?? 0.0,
              imagenUrl: prod['imagen_url'] ?? prod['imagenUrl'] ?? '',
              cantidad: row['cantidad'] ?? 1,
            ),
          );
        }
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar carrito de Supabase: $e');
    }
  }

  /// Llama esto al cerrar sesión: vacía la memoria sin borrar la BD
  void limpiarMemoriaLogout() {
    _items.clear();
    _idCarritoActivo = null;
    notifyListeners();
  }

  // ==========================================
  // OPERACIONES DEL CARRITO
  // ==========================================

  void addItem({
    required String id,
    required String nombre,
    required String marca,
    required double precio,
    required String imagenUrl,
  }) {
    // 🚀 Blindaje de seguridad: no permite agregar a memoria si no hay sesión iniciada
    final user = _supabase.auth.currentUser;
    if (user == null) {
      debugPrint('⚠️ [CartService] Intento de agregar al carrito sin sesión.');
      return;
    }

    final existingIndex = _items.indexWhere((item) => item.id == id || item.nombre == nombre);

    if (existingIndex >= 0) {
      _items[existingIndex].cantidad++;
      _sincronizarItemEnSupabase(id, _items[existingIndex].cantidad, precio);
    } else {
      _items.add(
        CartItemModel(
          id: id,
          nombre: nombre,
          marca: marca,
          precio: precio,
          imagenUrl: imagenUrl,
          cantidad: 1,
        ),
      );
      _sincronizarItemEnSupabase(id, 1, precio);
    }
    notifyListeners();
  }

  void increment(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].cantidad++;
      _sincronizarItemEnSupabase(_items[index].id, _items[index].cantidad, _items[index].precio);
      notifyListeners();
    }
  }

  void decrement(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
        _sincronizarItemEnSupabase(_items[index].id, _items[index].cantidad, _items[index].precio);
      } else {
        final prodId = _items[index].id;
        _items.removeAt(index);
        _eliminarItemEnSupabase(prodId);
      }
      notifyListeners();
    }
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      final prodId = _items[index].id;
      _items.removeAt(index);
      _eliminarItemEnSupabase(prodId);
      notifyListeners();
    }
  }

  Future<void> clear() async {
    _items.clear();
    notifyListeners();

    if (_idCarritoActivo != null) {
      try {
        await _supabase.from('carrito_item').delete().eq('id_carrito', _idCarritoActivo!);
      } catch (e) {
        debugPrint('Error al vaciar items de Supabase: $e');
      }
    }
  }

  // ==========================================
  // HELPERS PRIVADOS DE SUPABASE
  // ==========================================

  Future<int?> _obtenerOCrearCarritoId(String usuarioId) async {
    try {
      final carritoExistente = await _supabase
          .from('carrito')
          .select('id_carrito')
          .eq('usuario_id', usuarioId)
          .eq('estado', 'activo')
          .maybeSingle();

      if (carritoExistente != null) {
        return carritoExistente['id_carrito'] as int;
      }

      final nuevoCarrito = await _supabase
          .from('carrito')
          .insert({
            'usuario_id': usuarioId,
            'estado': 'activo',
          })
          .select('id_carrito')
          .single();

      return nuevoCarrito['id_carrito'] as int;
    } catch (e) {
      debugPrint('Error obteniendo/creando carrito: $e');
      return null;
    }
  }

  Future<void> _sincronizarItemEnSupabase(String productoId, int cantidad, double precio) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final pId = int.tryParse(productoId);
    if (pId == null) {
      debugPrint('⚠️ [CartService] Error: "$productoId" no es un ID entero válido. Asegúrate de pasar el ID numérico del producto.');
      return;
    }

    try {
      _idCarritoActivo ??= await _obtenerOCrearCarritoId(user.id);
      if (_idCarritoActivo == null) return;

      await _supabase.from('carrito_item').upsert(
        {
          'id_carrito': _idCarritoActivo,
          'id_producto': pId,
          'cantidad': cantidad,
          'precio_unitario': precio,
        },
        onConflict: 'id_carrito,id_producto',
      );
    } catch (e) {
      debugPrint('Error sincronizando item con Supabase: $e');
    }
  }

  Future<void> _eliminarItemEnSupabase(String productoId) async {
    if (_idCarritoActivo == null) return;

    final pId = int.tryParse(productoId);
    if (pId == null) return;

    try {
      await _supabase
          .from('carrito_item')
          .delete()
          .eq('id_carrito', _idCarritoActivo!)
          .eq('id_producto', pId);
    } catch (e) {
      debugPrint('Error eliminando item en Supabase: $e');
    }
  }
}