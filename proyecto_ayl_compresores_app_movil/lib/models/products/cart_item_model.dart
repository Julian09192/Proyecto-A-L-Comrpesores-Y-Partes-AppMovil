class CartItemModel {
  final String id;
  final String nombre;
  final String marca;
  final double precio;
  final String imagenUrl;
  int cantidad;

  CartItemModel({
    required this.id,
    required this.nombre,
    required this.marca,
    required this.precio,
    required this.imagenUrl,
    this.cantidad = 1,
  });

  double get subtotal => precio * cantidad;
}