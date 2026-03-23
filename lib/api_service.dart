import 'dart:convert';
import 'package:http/http.dart' as http;
import 'paquete.dart';

class ApiService {
  final String baseUrl = "http://localhost:8000";

  Future<int> login(String nombre, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/login"),
      body: {
        "nombre": nombre,
        "password": password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['id'];
    } else {
      throw Exception("Login incorrecto");
    }
  }

  Future<List<Paquete>> getPaquetes(int userId) async {
    final response = await http.get(
      Uri.parse("$baseUrl/paquetes/$userId"),
    );

    final data = jsonDecode(response.body);
    return data.map<Paquete>((e) => Paquete.fromJson(e)).toList();
  }

  Future<void> recolectar(int id) async {
    await http.put(Uri.parse("$baseUrl/paquete/$id/recolectar"));
  }

  Future<void> entregar(int id) async {
    await http.put(Uri.parse("$baseUrl/paquete/$id/entregar"));
  }
}