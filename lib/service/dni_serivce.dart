// ApiService para obtener los datos del DNI
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static Future<Map<String, dynamic>?> getdni(String dni) async {
    try {
      final response = await http.get(
        Uri.parse(
            "https://identidadwebapi.abexacloud.com/api/Identidad/obtenerDni?dni=$dni"),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return data['content'];
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }
}