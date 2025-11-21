import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  // ✅ CAMBIA ESTO - De localhost a tu dominio real
  static const String baseUrl = "https://luissvalencia.gt.tc/php";

  static Future<Map<String, dynamic>> login(String email, String password, String tipo) async {
    try {
      final url = Uri.parse('$baseUrl/login');
      final response = await http.post(
        url, 
        body: {
          'email': email,
          'password': password,
          'tipo_usuario': tipo,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        }
      ).timeout(Duration(seconds: 10));

      print('🔐 Login Response: ${response.statusCode}');
      print('📨 Login Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // ✅ MEJORADO: Retornar más información
        return {
          'success': data['success'] == true,
          'message': data['message'],
          'user_id': data['id'] ?? 0,
          'nombre': data['nombre'] ?? '',
          'tipo': data['tipo'] ?? '',
        };
      } else {
        return {
          'success': false,
          'message': 'Error de conexión: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('❌ Login Error: $e');
      return {
        'success': false,
        'message': 'Error de red: $e'
      };
    }
  }
}