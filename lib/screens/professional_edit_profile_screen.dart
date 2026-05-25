import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/professional_service.dart';
import '../utils/phone_number_utils.dart';

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

    late final String normalizedPhoneNumber;
    late final String normalizedWhatsappNumber;
    try {
      normalizedPhoneNumber = PhoneNumberUtils.normalizeColombianMobile(
        phoneNumber,
      );
      normalizedWhatsappNumber = PhoneNumberUtils.normalizeColombianMobile(
        whatsappNumber,
      );
    } catch (e) {
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
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
        phoneNumber: normalizedPhoneNumber,
        whatsappNumber: normalizedWhatsappNumber,
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

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Volver',
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.warmOrange,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.glassWhiteStrong,
              side: const BorderSide(color: AppTheme.glassBorder),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Editar perfil',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Actualiza la información que verán tus clientes',
          style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );
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
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.25,
            colors: [
              AppTheme.warmOrange.withAlpha(48),
              AppTheme.terracottaRed.withAlpha(30),
              AppTheme.darkBackgroundAlt,
              AppTheme.darkBackground,
            ],
            stops: const [0, 0.28, 0.62, 1],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
                Card(
                  color: AppTheme.glassWhiteStrong,
                  elevation: 10,
                  shadowColor: AppTheme.terracottaRed.withAlpha(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                    side: const BorderSide(color: AppTheme.glassBorder),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _fieldLabel('Nombre'),
                        TextField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Nombre profesional',
                          ),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Categoría'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            hintText: 'Selecciona una categoría',
                          ),
                          dropdownColor: AppTheme.darkBackgroundAlt,
                          style: const TextStyle(color: AppTheme.textWhite),
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
                              : (value) =>
                                    setState(() => _selectedCategory = value),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Ciudad'),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCity,
                          decoration: const InputDecoration(
                            hintText: 'Selecciona una ciudad',
                          ),
                          dropdownColor: AppTheme.darkBackgroundAlt,
                          style: const TextStyle(color: AppTheme.textWhite),
                          items: cityOptions
                              .map(
                                (city) => DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                              )
                              .toList(),
                          onChanged: _isLoading
                              ? null
                              : (value) =>
                                    setState(() => _selectedCity = value),
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Descripción'),
                        TextField(
                          controller: _descriptionController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Cuéntales a los clientes qué haces',
                          ),
                          minLines: 3,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('Teléfono'),
                        TextField(
                          controller: _phoneNumberController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Número de teléfono',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        _fieldLabel('WhatsApp'),
                        TextField(
                          controller: _whatsappNumberController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Número de WhatsApp',
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.terracottaRed,
                            foregroundColor: AppTheme.textWhite,
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppTheme.defaultRadius,
                              ),
                            ),
                          ),
                          onPressed: _isLoading ? null : _saveProfile,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('Guardar'),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
