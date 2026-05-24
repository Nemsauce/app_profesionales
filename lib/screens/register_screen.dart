import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 0 = none, 1 = client, 2 = professional
  int _selectedType = 0;

  // Form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedCategory;
  String? _selectedCity;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _accountOption({required String label, required IconData icon, required int type}) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D47A1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF0D47A1)),
        ),
        child: Row(
          children: [
            Icon(icon,
                size: 48,
                color: isSelected ? Colors.white : const Color(0xFF0D47A1)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF0D47A1),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    if (_selectedType == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 24),
        TextField(
          controller: _fullNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailController,
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
          decoration: const InputDecoration(
            labelText: 'Contraseña',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          decoration: const InputDecoration(
            labelText: 'Confirmar contraseña',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.lock),
          ),
          obscureText: true,
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
                .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                .toList(),
            value: _selectedCategory,
            onChanged: (v) => setState(() => _selectedCategory = v),
          ),
          const SizedBox(height: 16),
          // City dropdown
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              labelText: 'Ciudad',
              border: OutlineInputBorder(),
            ),
            items: AppConstants.mainCities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            value: _selectedCity,
            onChanged: (v) => setState(() => _selectedCity = v),
          ),
        ],
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D47A1),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            // TODO: implement signup logic
          },
          child: const Text('Crear cuenta'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear cuenta'),
        backgroundColor: const Color(0xFF0D47A1),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona tu tipo de cuenta',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _accountOption(label: 'Soy cliente', icon: Icons.person, type: 1),
            const SizedBox(height: 16),
            _accountOption(label: 'Soy profesional', icon: Icons.work, type: 2),
            _buildForm(),
          ],
        ),
      ),
    );
  }
}
