import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/login_response.dart';
import '../api/api_client.dart';

class AuthService {
  final _dio = apiClient.dio;

  Future<bool> login(String login, String password) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        "login": login,
        "password": password,
      });

      if (response.statusCode == 200) {
        final data = LoginResponse.fromJson(response.data);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data.token);
        return true;
      }
      return false;
    } on DioException catch (e) {
      throw "ERRO DA API: ${e.response?.statusCode} | ${e.message}";
    }
  }
}