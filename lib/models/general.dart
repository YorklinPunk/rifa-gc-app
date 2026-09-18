class General {
  final String id;
  final DateTime fechaRegistro;
  final DateTime fechaHoraSorteo;
  final String urlEnlaceSorteo;
  final String mensajeSorteo;
  final String subMensajeSorteo;

  General({
    required this.id,
    required this.fechaRegistro,
    required this.fechaHoraSorteo,
    required this.urlEnlaceSorteo,
    required this.mensajeSorteo,
    required this.subMensajeSorteo
  });

  factory General.fromJson(Map<String, dynamic> json) {
    return General(
      id: json['id'],      
      fechaRegistro: DateTime.parse(json['fechaRegistro']),
      fechaHoraSorteo: DateTime.parse(json['fechaHoraSorteo']),
      urlEnlaceSorteo: json['urlEnlaceSorteo'],
      mensajeSorteo: json['mensajeSorteo'],
      subMensajeSorteo: json['subMensajeSorteo']
    );
  }
}