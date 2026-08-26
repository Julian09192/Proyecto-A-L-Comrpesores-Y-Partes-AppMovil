class Usuario {
  final String id;
  final String nombre;
  final String correo;
  String rol;
  bool suspendido;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.rol,
    required this.suspendido,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? 'Sin nombre',
      correo: json['correo'] ?? 'Sin correo',
      rol: json['rol'] ?? 'cliente',
      suspendido: json['suspendido'] ?? false,
    );
  }
}