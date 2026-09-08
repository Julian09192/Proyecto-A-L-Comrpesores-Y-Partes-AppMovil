class ReporteInventarioResponse {
  final String tipoReporte;
  final ReporteResumen resumen;
  final List<ReporteCategoria> categorias;
  final List<String> proveedores;
  final List<ReporteProducto> productos;

  ReporteInventarioResponse({
    required this.tipoReporte,
    required this.resumen,
    required this.categorias,
    required this.proveedores,
    required this.productos,
  });

  factory ReporteInventarioResponse.fromJson(Map<String, dynamic> json) {
    return ReporteInventarioResponse(
      tipoReporte: json['tipo_reporte']?.toString() ?? 'stock',
      resumen: ReporteResumen.fromJson(json['resumen'] ?? {}),
      categorias: (json['categorias'] as List<dynamic>? ?? [])
          .map((item) => ReporteCategoria.fromJson(item))
          .toList(),
      proveedores: (json['proveedores'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      productos: (json['productos'] as List<dynamic>? ?? [])
          .map((item) => ReporteProducto.fromJson(item))
          .toList(),
    );
  }
}

class ReporteResumen {
  final int totalProductos;
  final int stockTotal;
  final double valorTotal;

  ReporteResumen({
    required this.totalProductos,
    required this.stockTotal,
    required this.valorTotal,
  });

  factory ReporteResumen.fromJson(Map<String, dynamic> json) {
    return ReporteResumen(
      totalProductos: json['total_productos'] is int
          ? json['total_productos']
          : int.tryParse(json['total_productos'].toString()) ?? 0,
      stockTotal: json['stock_total'] is int
          ? json['stock_total']
          : int.tryParse(json['stock_total'].toString()) ?? 0,
      valorTotal: (json['valor_total'] is num)
          ? (json['valor_total'] as num).toDouble()
          : double.tryParse(json['valor_total'].toString()) ?? 0.0,
    );
  }
}

class ReporteCategoria {
  final String categoria;
  final int productos;
  final int stockTotal;
  final double valorTotal;

  ReporteCategoria({
    required this.categoria,
    required this.productos,
    required this.stockTotal,
    required this.valorTotal,
  });

  factory ReporteCategoria.fromJson(Map<String, dynamic> json) {
    return ReporteCategoria(
      categoria: json['categoria']?.toString() ?? 'Sin categoría',
      productos: json['productos'] is int
          ? json['productos']
          : int.tryParse(json['productos'].toString()) ?? 0,
      stockTotal: json['stock_total'] is int
          ? json['stock_total']
          : int.tryParse(json['stock_total'].toString()) ?? 0,
      valorTotal: (json['valor_total'] is num)
          ? (json['valor_total'] as num).toDouble()
          : double.tryParse(json['valor_total'].toString()) ?? 0.0,
    );
  }
}

class ReporteProducto {
  final dynamic id;
  final String nombre;
  final String tipo;
  final String marca;
  final int stockTotal;
  final double precio;
  final String codigoInterno;
  final bool suspendido;

  ReporteProducto({
    required this.id,
    required this.nombre,
    required this.tipo,
    required this.marca,
    required this.stockTotal,
    required this.precio,
    required this.codigoInterno,
    required this.suspendido,
  });

  factory ReporteProducto.fromJson(Map<String, dynamic> json) {
    final susp = json['suspendido'];
    final bool esSuspendido = (susp == true || susp == 1 || susp == '1');

    return ReporteProducto(
      id: json['id'],
      nombre: json['nombre']?.toString() ?? 'Sin nombre',
      tipo: json['tipo']?.toString() ?? 'General',
      marca: json['marca']?.toString() ?? 'Sin marca',
      stockTotal: json['stock_total'] is int
          ? json['stock_total']
          : int.tryParse(json['stock_total'].toString()) ?? 0,
      precio: (json['precio'] is num)
          ? (json['precio'] as num).toDouble()
          : double.tryParse(json['precio'].toString()) ?? 0.0,
      codigoInterno: json['codigo_interno']?.toString() ?? 'REF-${json['id']}',
      suspendido: esSuspendido,
    );
  }
}