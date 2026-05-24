import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../models/professional.dart';
import '../services/professional_service.dart';

class ProfessionalEditProfileScreen extends StatefulWidget {
  const ProfessionalEditProfileScreen({super.key, required this.professional});

  final Professional professional;

  @override
  State<ProfessionalEditProfileScreen> createState() =>
      _ProfessionalEditProfileScreenState();
}

class _ProfessionalEditProfileScreenState
    extends State<ProfessionalEditProfileScreen> {
  final _professionalService = ProfessionalService();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _whatsappNumberController;
  String? _selectedCategory;
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final professional = widget.professional;

    _nameController = TextEditingController(text: professional.name);
    _descriptionController = TextEditingController(
      text: professional.description,
    );
    _phoneNumberController = TextEditingController(
      text: professional.phoneNumber,
    );
    _whatsappNumberController = TextEditingController(
      text: professional.whatsappNumber,
    );
    _selectedCategory = professional.category.trim().isEmpty
        ? null
        : professional.category;
    _selectedCity = professional.city.trim().isEmpty ? null : professional.city;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    _whatsappNumberController.dispose();
    super.dispose();
  }

  List<String> _optionsWithCurrentValue(List<String> options, String? current) {
    if (current == null || current.isEmpty || options.contains(current)) {
      return options;
    }

    return [...options, current];
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveProfile() async {
    if (_isLoading) return;

    final name = _nameController.text.trim();
    final description = _descriptionController.text.trim();
    final phoneNumber = _phoneNumberController.text.trim();
    final whatsappNumber = _whatsappNumberController.text.trim();
    final category = _selectedCategory?.trim() ?? '';
    final city = _selectedCity?.trim() ?? '';

    if (name.isEmpty ||
        category.isEmpty ||
        city.isEmpty ||
        phoneNumber.isEmpty ||
        whatsappNumber.isEmpty) {
      _showSnackBar('Completa todos los campos obligatorios del perfil.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _professionalService.updateProfessionalProfile(
        professionalId: widget.professional.id,
        name: name,
        description: description,
        category: category,
        city: city,
        phoneNumber: phoneNumber,
        whatsappNumber: whatsappNumber,
      );

      if (!mounted) return;
      _showSnackBar('Perfil actualizado correctamente');
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

  @override
  Widget build(BuildContext context) {
    final categoryOptions = _optionsWithCurrentValue(
      AppConstants.serviceCategories,
      _selectedCategory,
    );
    final cityOptions = _optionsWithCurrentValue(
      AppConstants.mainCities,
      _selectedCity,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: categoryOptions
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
              items: cityOptions
                  .map(
                    (city) => DropdownMenuItem(value: city, child: Text(city)),
                  )
                  .toList(),
              onChanged: _isLoading
                  ? null
                  : (value) => setState(() => _selectedCity = value),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              minLines: 3,
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneNumberController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _whatsappNumberController,
              decoration: const InputDecoration(
                labelText: 'WhatsApp',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
