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
        description.isEmpty ||
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

  Widget _buildGlassCard({
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(22),
    EdgeInsetsGeometry? margin,
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(34),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _helpText(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textWhiteMuted,
          fontSize: 12,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              tooltip: 'Volver',
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              color: AppTheme.textWhite,
              style: IconButton.styleFrom(
                backgroundColor: AppTheme.glassWhiteSoft,
                side: const BorderSide(color: AppTheme.glassBorder),
              ),
            ),
            const SizedBox(width: 14),
            Container(
              height: 62,
              width: 62,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.terracottaRed.withAlpha(150),
                    AppTheme.warmOrange.withAlpha(105),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warmOrange.withAlpha(34),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Icon(
                Icons.manage_accounts_outlined,
                color: AppTheme.textWhite,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Editar perfil',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      height: 1.05,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Completa tu información para aparecer en el marketplace.',
                    style: TextStyle(
                      color: AppTheme.textWhiteMuted,
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVisibilityNoteCard() {
    return _buildGlassCard(
      padding: const EdgeInsets.all(18),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 42,
              width: 42,
              decoration: BoxDecoration(
                color: AppTheme.warmOrange.withAlpha(30),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.glassBorder),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                color: AppTheme.warmOrange,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu perfil debe estar completo para ser visible para clientes.',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Nombre, categoría, ciudad, descripción, teléfono y WhatsApp deben estar completos.',
                    style: TextStyle(
                      color: AppTheme.textWhiteMuted,
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileFormCard({
    required List<String> categoryOptions,
    required List<String> cityOptions,
  }) {
    return _buildGlassCard(
      padding: const EdgeInsets.all(24),
      children: [
        const Text(
          'Información del perfil',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Estos datos son los que verán los clientes antes de contactarte.',
          style: TextStyle(color: AppTheme.textWhiteMuted, height: 1.35),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        _fieldLabel('Nombre'),
        TextField(
          controller: _nameController,
          enabled: !_isLoading,
          decoration: const InputDecoration(
            hintText: 'Nombre profesional',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Categoría'),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            hintText: 'Selecciona una categoría',
            prefixIcon: Icon(Icons.home_repair_service_outlined),
          ),
          dropdownColor: AppTheme.darkBackgroundAlt,
          style: const TextStyle(color: AppTheme.textWhite),
          items: categoryOptions
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: _isLoading
              ? null
              : (value) => setState(() => _selectedCategory = value),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Ciudad'),
        DropdownButtonFormField<String>(
          initialValue: _selectedCity,
          decoration: const InputDecoration(
            hintText: 'Selecciona una ciudad',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
          dropdownColor: AppTheme.darkBackgroundAlt,
          style: const TextStyle(color: AppTheme.textWhite),
          items: cityOptions
              .map((city) => DropdownMenuItem(value: city, child: Text(city)))
              .toList(),
          onChanged: _isLoading
              ? null
              : (value) => setState(() => _selectedCity = value),
        ),
        const SizedBox(height: 16),
        _fieldLabel('Descripción'),
        TextField(
          controller: _descriptionController,
          enabled: !_isLoading,
          decoration: const InputDecoration(
            hintText: 'Cuéntales a los clientes qué haces',
            prefixIcon: Icon(Icons.description_outlined),
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
            prefixIcon: Icon(Icons.phone_outlined),
          ),
          keyboardType: TextInputType.phone,
        ),
        _helpText('Usa un número móvil colombiano, por ejemplo 3001234567.'),
        const SizedBox(height: 16),
        _fieldLabel('WhatsApp'),
        TextField(
          controller: _whatsappNumberController,
          enabled: !_isLoading,
          decoration: const InputDecoration(
            hintText: 'Número de WhatsApp',
            prefixIcon: Icon(Icons.chat_bubble_outline),
          ),
          keyboardType: TextInputType.phone,
        ),
        _helpText('Usa un número móvil colombiano, por ejemplo 3001234567.'),
        const SizedBox(height: 24),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.terracottaRed,
            foregroundColor: AppTheme.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
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
              : const Text('Guardar cambios'),
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
                const SizedBox(height: 18),
                _buildVisibilityNoteCard(),
                const SizedBox(height: 18),
                _buildProfileFormCard(
                  categoryOptions: categoryOptions,
                  cityOptions: cityOptions,
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
