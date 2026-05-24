import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _authService = AuthService();

  // 0 = none, 1 = client, 2 = professional
  int _selectedType = 0;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCity;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _register() async {
    if (_isLoading) return;

    final name = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phoneNumber = _phoneController.text.trim();
    final whatsappNumber = _whatsappController.text.trim();

    if (_selectedType == 0) {
      _showSnackBar('Selecciona si eres cliente o profesional.');
      return;
    }

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedCity == null) {
      _showSnackBar('Completa todos los campos requeridos.');
      return;
    }

    if (password != confirmPassword) {
      _showSnackBar('Las contraseñas no coinciden.');
      return;
    }

    if (_selectedType == 2 &&
        (_selectedCategory == null ||
            phoneNumber.isEmpty ||
            whatsappNumber.isEmpty)) {
      _showSnackBar('Completa todos los campos del profesional.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_selectedType == 1) {
        await _authService.registerClient(
          name: name,
          email: email,
          password: password,
          city: _selectedCity!,
        );
      } else {
        await _authService.registerProfessional(
          name: name,
          email: email,
          password: password,
          category: _selectedCategory!,
          city: _selectedCity!,
          phoneNumber: phoneNumber,
          whatsappNumber: whatsappNumber,
        );
      }

      if (!mounted) return;
      _showSnackBar('Cuenta creada correctamente');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _accountOption({
    required String label,
    required IconData icon,
    required int type,
  }) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryBlue : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryBlue),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 48,
              color: isSelected ? Colors.white : AppTheme.primaryBlue,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_selectedType == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos de la cuenta',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _fullNameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(
                              () => _obscurePassword = !_obscurePassword,
                            );
                          },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _obscurePassword,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            );
                          },
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                  ),
                ),
                obscureText: _obscureConfirmPassword,
              ),
              if (_selectedType == 2) ...[
                const SizedBox(height: 16),
                // Category dropdown
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Categoría de servicio',
                    border: OutlineInputBorder(),
                  ),
                  items: AppConstants.serviceCategories
                      .map(
                        (cat) => DropdownMenuItem(value: cat, child: Text(cat)),
                      )
                      .toList(),
                  initialValue: _selectedCategory,
                  onChanged: _isLoading
                      ? null
                      : (v) => setState(() => _selectedCategory = v),
                ),
              ],
              const SizedBox(height: 16),
              // City dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Ciudad',
                  border: OutlineInputBorder(),
                ),
                items: AppConstants.mainCities
                    .map(
                      (city) =>
                          DropdownMenuItem(value: city, child: Text(city)),
                    )
                    .toList(),
                initialValue: _selectedCity,
                onChanged: _isLoading
                    ? null
                    : (v) => setState(() => _selectedCity = v),
              ),
              if (_selectedType == 2) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _whatsappController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    labelText: 'WhatsApp',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.chat),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Crear cuenta',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Elige tu tipo de cuenta y completa tus datos',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Selecciona tu tipo de cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    _accountOption(
                      label: 'Soy cliente',
                      icon: Icons.person,
                      type: 1,
                    ),
                    const SizedBox(height: 16),
                    _accountOption(
                      label: 'Soy profesional',
                      icon: Icons.work,
                      type: 2,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildForm(),
          ],
        ),
      ),
    );
  }
}
