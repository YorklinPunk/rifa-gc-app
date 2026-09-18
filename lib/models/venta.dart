class Venta {
  final String id;
  final String idVendedor;
  final String vendedor;
  final String cliente;
  final String telefono;
  final List<int> numeros;
  final DateTime fechaRegistro;

  Venta({
    required this.id,
    required this.idVendedor,
    required this.vendedor,
    required this.cliente,
    required this.telefono,
    required this.numeros,
    required this.fechaRegistro,
  });

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      id: json['id'],
      idVendedor: json['idVendedor'],
      vendedor: json['vendedor'],
      cliente: json['cliente'],
      telefono: json['telefono'],
      numeros: List<int>.from(json['numeros']),
      fechaRegistro: DateTime.parse(json['fechaRegistro'])
    );
  }
}