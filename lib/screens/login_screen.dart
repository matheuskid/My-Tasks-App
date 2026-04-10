import 'package:flutter/material.dart';
import 'package:todo_app/controllers/login_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final LoginController _controller = LoginController();
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(
              controller: _controller.loginController,
              decoration: const InputDecoration(labelText: "Usuário", border: OutlineInputBorder()),
              autofillHints: const [AutofillHints.username],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller.passwordController,
              obscureText: _isObscure,
              decoration: InputDecoration(
                labelText: "Senha",
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_isObscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _isObscure = !_isObscure),
                ),
              ),
              autofillHints: const [AutofillHints.password],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _controller.handleLogin(context),
                child: const Text("ENTRAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}