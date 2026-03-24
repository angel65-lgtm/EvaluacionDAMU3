import 'dart:convert';
import 'package:http/http.dart' as http;
import 'paquete.dart';

class ApiService {

  static const String baseUrl = "http://127.0.0.1:8000";

  // 🔐 LOGIN (FORM-DATA)
  static Future<Map<String, dynamic>> login(String usuario, String password) async {

    final response = await http.post(
      Uri.parse("$baseUrl/login/"),
      body: {
        "usr_nombre": usuario,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Error login");
    }
  }

  // 📦 OBTENER PAQUETES
  Future<List<Paquete>> getPaquetes(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/paquetes/$userId"),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data.map<Paquete>((e) => Paquete.fromJson(e)).toList();
    } else {
      throw Exception("Error al obtener paquetes");
    }
  }

  // 📥 RECOLECTAR
  Future<void> recolectar(int id) async {
    final response = await http.put(
      Uri.parse("$baseUrl/paquete/$id/recolectar"),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al recolectar");
    }
  }

  // 📤 ENTREGAR
  Future<void> entregar(int id) async {
    final response = await http.put(
      Uri.parse("$baseUrl/paquete/$id/entregar"),
    );

    if (response.statusCode != 200) {
      throw Exception("Error al entregar");
    }
  }
}