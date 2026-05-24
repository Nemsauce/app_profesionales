import 'package:flutter/material.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
        return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: const Color(0xFF0D47A1), // dark blue
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo / icon
            const SizedBox(height: 40),
            const Icon(
              Icons.work,
              size: 100,
              color: Color(0xFF0D47A1),
            ),
            const SizedBox(height: 48),
            // Email field
            TextField(
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            // Password field
            TextField(
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            // Iniciar sesión button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D47A1), // dark blue
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                // TODO: implement sign‑in logic
              },
              child: const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 12),
            // Registrarse button (outline style)
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF0D47A1)),
                foregroundColor: const Color(0xFF0D47A1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Registrarse'),
            ),
            const SizedBox(height: 24),
            // Divider with text
            Row(
              children: const [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text('o'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),
            // Continue with Google button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800), // orange
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: const Icon(Icons.login), // placeholder icon
              label: const Text('Continuar con Google'),
              onPressed: () {
                // TODO: implement Google sign‑in
              },
            ),
          ],
        ),
      ),
    );
  }
}
