class Paquete {
  final int id;
  final String nombre;
  final String descripcion;
  final String destino;
  final String status;
  final String imagen;

  Paquete({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.destino,
    required this.status,
    required this.imagen,
  });

  factory Paquete.fromJson(Map<String, dynamic> json) {
    return Paquete(
      id: json["id"],
      nombre: json["nombre"],
      descripcion: json["descripcion"] ?? "",
      destino: json["destino"] ?? "",
      status: json["status"],
      imagen: json["imagen"] ?? "",
    );
  }
}