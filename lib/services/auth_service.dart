import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_respose.dart' show LoginResponse;

class AuthService {

  static const String baseUrl = String.fromEnvironment(
    'API_URL', 
    defaultValue: 'http://localhost:8080'
  );

  
  Future<bool> login(String login, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"login": login, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = LoginResponse.fromJson(jsonDecode(response.body));
      
      final prefs = await SharedPreferences.getInstance();
      // Salva o token no "cofre" do celular
      await prefs.setString('jwt_token', data.token);
      return true;
    } else {
      throw "ERRO DA API: Status ${response.statusCode} | Body: ${response.body}";
    }
  }
}