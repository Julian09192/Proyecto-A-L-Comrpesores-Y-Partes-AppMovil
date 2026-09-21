class MovimientoBitacora {
  final int id;
  final String accion;
  final String modulo;
  final String detalles;
  final String usuarioEmail;
  final DateTime? createdAt;

  MovimientoBitacora({
    required this.id,
    required this.accion,
    required this.modulo,
    required this.detalles,
    required this.usuarioEmail,
    this.createdAt,
  });

  factory MovimientoBitacora.fromJson(Map<String, dynamic> json) {
    return MovimientoBitacora(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
      accion: json['accion']?.toString() ?? 'DESCONOCIDO',
      modulo: json['modulo']?.toString() ?? 'General',
      detalles: json['detalles']?.toString() ?? '',
      usuarioEmail: json['usuario_email']?.toString() ?? 'Sistema',
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  // Formateo de fecha tipo: "27/08/2026, 08:52 p. m."
  String get fechaFormateada {
    if (createdAt == null) return 'Sin fecha';
    final f = createdAt!.toLocal();
    final dia = f.day.toString().padLeft(2, '0');
    final mes = f.month.toString().padLeft(2, '0');
    final anio = f.year;
    
    int hora = f.hour > 12 ? f.hour - 12 : (f.hour == 0 ? 12 : f.hour);
    final horaStr = hora.toString().padLeft(2, '0');
    final min = f.minute.toString().padLeft(2, '0');
    final periodo = f.hour >= 12 ? 'p. m.' : 'a. m.';

    return '$dia/$mes/$anio, $horaStr:$min $periodo';
  }
}