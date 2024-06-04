import 'dart:convert';
import 'package:http/http.dart' as http;

class ServicioAPI {

  Future<Map<String, dynamic>> obtenerTasasCambio(Uri url) async {

    var headers = {'consumer': 'Jorge Enmanuel Jesus Rodriguez Rodriguez'};
    var response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al obtener las tasas de cambio');
    }
  }
}