import 'dart:convert';
import 'package:http/http.dart' as http;
import 'paquete.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // En laptop/Chrome, localhost es más estable
  static const String baseUrl = "http://localhost:8000";

  // 🔐 LOGIN
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
  Future<void> recolectar(int id, int userId) async {
    final response = await http.put(
      Uri.parse("$baseUrl/paquete/$id/recolectar"),
      body: {
        "usuario_id": userId.toString(),
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Error al recolectar");
    }
  }

  // 📤 ENTREGAR (Versión final para Laptop/Chrome)
  Future<void> entregar(int id, XFile imageFile, String attendance, double lat, double lng) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse("$baseUrl/paquete/$id/entregar"),
    );

    // Campos de texto
    request.fields['attendance'] = attendance;
    request.fields['latitud'] = lat.toString();
    request.fields['longitud'] = lng.toString();

    // Importante para Web: Leer bytes del XFile
    var bytes = await imageFile.readAsBytes();
    var multipartFile = http.MultipartFile.fromBytes(
      'foto', 
      bytes,
      filename: imageFile.name,
    );
    
    request.files.add(multipartFile);

    // Enviamos y esperamos respuesta completa para ver errores
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200) {
      print("Error del servidor: ${response.body}");
      throw Exception("Error al entregar: ${response.statusCode}");
    }
  }
}