class ProductoModel {
  final int id;
  final String nombre;
  final String caracteristicas;
  final double precio;
  final int stockTotal;
  final String tipo;
  final int? bodegaId;
  final String marca;
  final String? codigoInterno;
  final String? imagenUrl;
  final String? cloudinaryImagenPublicId;
  final bool suspendido;

  ProductoModel({
    required this.id,
    required this.nombre,
    required this.caracteristicas,
    required this.precio,
    required this.stockTotal,
    required this.tipo,
    this.bodegaId,
    required this.marca,
    this.codigoInterno,
    this.imagenUrl,
    this.cloudinaryImagenPublicId,
    this.suspendido = false,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      nombre: json['nombre'] ?? '',
      caracteristicas: json['caracteristicas'] ?? '',
      precio: (json['precio'] as num?)?.toDouble() ?? 0.0,
      stockTotal: json['stock_total'] is int
          ? json['stock_total']
          : int.tryParse(json['stock_total']?.toString() ?? '0') ?? 0,
      tipo: json['tipo'] ?? 'General',
      bodegaId: json['bodega_id'] is int
          ? json['bodega_id']
          : int.tryParse(json['bodega_id']?.toString() ?? ''),
      marca: json['marca'] ?? 'Genérico',
      codigoInterno: json['codigo_interno'],
      imagenUrl: json['imagen_url'],
      cloudinaryImagenPublicId: json['cloudinary_imagen_public_id'],
      suspendido: json['suspendido'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'caracteristicas': caracteristicas,
      'precio': precio,
      'stock_total': stockTotal,
      'tipo': tipo,
      if (bodegaId != null) 'bodega_id': bodegaId,
      'marca': marca,
      if (codigoInterno != null) 'codigo_interno': codigoInterno,
      if (imagenUrl != null) 'imagen_url': imagenUrl,
      if (cloudinaryImagenPublicId != null)
        'cloudinary_imagen_public_id': cloudinaryImagenPublicId,
      'suspendido': suspendido,
    };
  }
}