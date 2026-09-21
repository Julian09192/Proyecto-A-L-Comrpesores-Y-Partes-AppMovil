import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoritosService extends ChangeNotifier {
  static final FavoritosService _instance = FavoritosService._internal();
  factory FavoritosService() => _instance;
  FavoritosService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  final Set<String> _favoritosIds = {};

  Set<String> get favoritosIds => Set.unmodifiable(_favoritosIds);

  /// Devuelve los IDs como Set o List para compatibilidad con productos_screen
  Future<Set<String>> obtenerIdsFavoritos() async {
    final user = _supabase.auth.currentUser;
    // Si no hay sesión, no hay favoritos que cargar
    if (user == null) {
      _favoritosIds.clear();
      return {};
    }

    if (_favoritosIds.isEmpty) {
      await cargarFavoritosUsuario();
    }
    return _favoritosIds;
  }

  /// Verifica si un ID está en favoritos (acepta String o int)
  bool esFavorito(dynamic productoId) {
    if (productoId == null) return false;
    return _favoritosIds.contains(productoId.toString());
  }

  // ==========================================
  // GESTIÓN DE SESIÓN (LOGIN / LOGOUT)
  // ==========================================

  Future<void> cargarFavoritosUsuario() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      _favoritosIds.clear();
      notifyListeners();
      return;
    }

    try {
      final response = await _supabase
          .from('favoritos')
          .select('producto_id')
          .eq('usuario_id', user.id);

      _favoritosIds.clear();
      for (var row in (response as List)) {
        if (row['producto_id'] != null) {
          _favoritosIds.add(row['producto_id'].toString());
        }
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error al cargar favoritos de Supabase: $e');
    }
  }

  void limpiarMemoriaLogout() {
    _favoritosIds.clear();
    notifyListeners();
  }

  // ==========================================
  // OPERACIONES DE FAVORITOS (TOGGLE)
  // ==========================================

  Future<void> toggleFavorito(dynamic productoId) async {
    final user = _supabase.auth.currentUser;

    // 🚀 1. Si no hay sesión, lanzamos 'no_auth' para que la UI lo atrape
    if (user == null) {
      throw 'no_auth';
    }

    final idStr = productoId.toString();
    final pId = int.tryParse(idStr);

    if (pId == null) {
      debugPrint('⚠️ [FavoritosService] El id "$productoId" no es numérico.');
      return;
    }

    if (_favoritosIds.contains(idStr)) {
      _favoritosIds.remove(idStr);
      notifyListeners();

      try {
        await _supabase
            .from('favoritos')
            .delete()
            .eq('usuario_id', user.id)
            .eq('producto_id', pId);
      } catch (e) {
        debugPrint('Error eliminando favorito de Supabase: $e');
      }
    } else {
      _favoritosIds.add(idStr);
      notifyListeners();

      try {
        await _supabase.from('favoritos').upsert(
          {
            'usuario_id': user.id,
            'producto_id': pId,
          },
          onConflict: 'usuario_id,producto_id',
        );
      } catch (e) {
        debugPrint('Error agregando favorito en Supabase: $e');
      }
    }
  }
}