import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rifa_gc/models/general.dart';
import 'package:rifa_gc/models/vendedor.dart';
import 'package:rifa_gc/models/venta.dart';

class ApiService {
  // Para desarrollo local.
  // Si pruebas desde un celular físico, localhost NO será tu PC.
  // static const String baseUrl = 'https://18ab-191-98-157-133.ngrok-free.app';
  static const String baseUrl = 'https://rifa-webapi.abexacloud.com';

  static Future<List<int>> obtenerNumerosVendidos() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ventas'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener las ventas: ${response.statusCode}',
      );
    }

    final List<dynamic> ventas = jsonDecode(response.body);

    final Set<int> numerosVendidos = {};

    for (final venta in ventas) {
      final List<dynamic> numeros = venta['numeros'] ?? [];

      for (final numero in numeros) {
        numerosVendidos.add(
          int.parse(numero.toString()),
        );
      }
    }

    return numerosVendidos.toList()..sort();
  }

  static Future<Venta> guardarVenta({
    // guardar object id de vendedor 
    required String idVendedor,     
    required String vendedor,
    required String cliente,
    required String telefono,
    required List<int> numeros,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/ventas'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'idVendedor': idVendedor,
        'vendedor': vendedor,
        'cliente': cliente,
        'telefono': telefono,
        'numeros': numeros,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);

      return Venta.fromJson(data);
    }

    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);

      final numerosOcupados =
          (data['numeros'] as List?)?.join(', ') ?? '';

      throw Exception(
        'Los siguientes números ya fueron vendidos: '
        '$numerosOcupados',
      );
    }

    try {
      final data = jsonDecode(response.body);
      throw Exception(
        data['mensaje'] ??
            'No se pudo registrar la venta.',
      );
    } catch (_) {
      throw Exception(
        'Error al registrar la venta. '
        'Código: ${response.statusCode}',
      );
    }
  }

  static Future<List<Venta>> obtenerVentas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/ventas'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener las ventas: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return Venta(
        id: item['id'].toString(),
        idVendedor: item['idVendedor'] ?? '',
        vendedor: item['vendedor'] ?? '',
        cliente: item['cliente'] ?? '',
        telefono: item['telefono'] ?? '',
        numeros: List<int>.from(
          (item['numeros'] ?? []).map(
            (numero) => int.parse(numero.toString()),
          ),
        ),
        fechaRegistro: DateTime.parse(
          item['fechaRegistro'],
        ),
      );
    }).toList();
  }

  static Future<void> eliminarVenta(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/ventas/$id'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 404) {
      throw Exception('La venta no existe.');
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje'] ?? 'No se pudo eliminar la venta.',
      );
    } catch (_) {
      throw Exception(
        'Error al eliminar la venta. '
        'Código: ${response.statusCode}',
      );
    }
  }

  static Future<void> actualizarVenta({
    required String id,
    required String idVendedor,
    required String vendedor,
    required String cliente,
    required String telefono,
    required List<int> numeros,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/ventas/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'idVendedor': idVendedor,
        'vendedor': vendedor,
        'cliente': cliente,
        'telefono': telefono,
        'numeros': numeros,
      }),
    );

    if (response.statusCode == 200) {
      return;
    }

    if (response.statusCode == 409) {
      final data = jsonDecode(response.body);

      final numerosOcupados =
          (data['numeros'] as List?)?.join(', ') ?? '';

      throw Exception(
        'Los siguientes números ya fueron vendidos: '
        '$numerosOcupados',
      );
    }

    try {
      final data = jsonDecode(response.body);

      throw Exception(
        data['mensaje'] ??
            'No se pudo actualizar la venta.',
      );
    } catch (_) {
      throw Exception(
        'Error al actualizar la venta. '
        'Código: ${response.statusCode}',
      );
    }
  }

  static Future<List<Vendedor>> obtenerVendedores() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/vendedores'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener los vendedores: ${response.statusCode}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body);

    return data.map((item) {
      return Vendedor(
        idVendedor: item['id'].toString(),
        nombreVendedor: item['nombreVendedor'] ?? '',
        fechaRegistro: DateTime.parse(
          item['fechaRegistro'],
        ),
      );
    }).toList();
  }

  static Future<General> obtenerInformacion() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/general'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener la información: ${response.statusCode}',
      );
    }

    final data = jsonDecode(response.body);

    return General.fromJson(data);
  }
}