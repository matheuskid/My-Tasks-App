import 'package:flutter/material.dart';
import 'package:todo_app/services/auth_service.dart';

class LoginController {
  final AuthService _authService = AuthService();
  final TextEditingController loginController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> handleLogin(BuildContext context) async {
    String login = loginController.text;
    String password = passwordController.text;

    if (login.isEmpty || password.isEmpty) {
      _showSnackBar(context, "Preencha todos os campos!");
      return;
    }

    bool success = await _authService.login(login, password);

    if (success && context.mounted) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      _showSnackBar(context, "Falha no login. Verifique suas credenciais.");
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}