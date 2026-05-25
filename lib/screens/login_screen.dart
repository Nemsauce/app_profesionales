import 'package:flutter/material.dart';
import '../constants/app_theme.dart';
import 'register_screen.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _login() async {
    if (_isLoading) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Ingresa correo electrónico y contraseña.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.login(email: email, password: password);

      if (!mounted) return;
      _showSnackBar('Inicio de sesión exitoso');
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.25,
            colors: [
              AppTheme.warmOrange.withAlpha(54),
              AppTheme.terracottaRed.withAlpha(34),
              AppTheme.darkBackgroundAlt,
              AppTheme.darkBackground,
            ],
            stops: const [0, 0.28, 0.62, 1],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.screenPadding),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 16),
                      _buildBrandHeader(),
                      const SizedBox(height: 40),
                      _buildLoginCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandHeader() {
    return Column(
      children: [
        Container(
          height: 76,
          width: 76,
          decoration: BoxDecoration(
            color: AppTheme.glassWhiteStrong,
            borderRadius: BorderRadius.circular(AppTheme.largeRadius),
            border: Border.all(color: AppTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.terracottaRed.withAlpha(72),
                blurRadius: 28,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_repair_service,
            color: AppTheme.warmOrange,
            size: 36,
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'ServiColombia',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Servicios a tu alcance',
          style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 16),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Card(
      color: AppTheme.glassWhiteStrong,
      elevation: 10,
      shadowColor: AppTheme.terracottaRed.withAlpha(64),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Bienvenido',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Inicia sesión para continuar',
              style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            const Text(
              'Correo electrónico',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _emailController,
              enabled: !_isLoading,
              decoration: const InputDecoration(
                hintText: 'correo@ejemplo.com',
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 18),
            const Text(
              'Contraseña',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: 'Tu contraseña',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              obscureText: _obscurePassword,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.terracottaRed,
                foregroundColor: AppTheme.textWhite,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                ),
              ),
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Iniciar sesión'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.warmOrange,
                side: const BorderSide(color: AppTheme.warmOrange),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
