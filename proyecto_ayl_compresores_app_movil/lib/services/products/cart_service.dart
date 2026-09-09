import 'package:flutter/material.dart';
import '../../models/products/cart_item_model.dart';

class CartService extends ChangeNotifier {
  // Singleton para usar la misma instancia en toda la app
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  // Total de unidades para el badge del AppBar
  int get totalItemsCount => _items.fold(0, (sum, item) => sum + item.cantidad);

  // Monto total en COP
  double get totalAmount => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  // Agregar producto al carrito
  void addItem({
    required String id,
    required String nombre,
    required String marca,
    required double precio,
    required String imagenUrl,
  }) {
    final existingIndex = _items.indexWhere((item) => item.id == id || item.nombre == nombre);

    if (existingIndex >= 0) {
      _items[existingIndex].cantidad++;
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
    }
    notifyListeners();
  }

  // Incrementar cantidad
  void increment(int index) {
    if (index >= 0 && index < _items.length) {
      _items[index].cantidad++;
      notifyListeners();
    }
  }

  // Decrementar cantidad o remover si llega a 0
  void decrement(int index) {
    if (index >= 0 && index < _items.length) {
      if (_items[index].cantidad > 1) {
        _items[index].cantidad--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  // Eliminar un ítem
  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  // Limpiar carrito
  void clear() {
    _items.clear();
    notifyListeners();
  }
}