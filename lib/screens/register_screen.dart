import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../utils/phone_number_utils.dart';

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

    String? normalizedPhoneNumber;
    String? normalizedWhatsappNumber;
    if (_selectedType == 2) {
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
          phoneNumber: normalizedPhoneNumber!,
          whatsappNumber: normalizedWhatsappNumber!,
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
    required String subtitle,
    required IconData icon,
    required int type,
  }) {
    final bool isSelected = _selectedType == type;
    return GestureDetector(
      onTap: _isLoading ? null : () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.terracottaRed.withAlpha(70)
              : AppTheme.glassWhiteSoft,
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          border: Border.all(
            color: isSelected ? AppTheme.warmOrange : AppTheme.glassBorder,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.terracottaRed.withAlpha(48),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? AppTheme.warmOrange
                    : AppTheme.textWhiteSubtle,
                size: 18,
              ),
            ),
            Icon(
              icon,
              size: 30,
              color: isSelected ? AppTheme.textWhite : AppTheme.warmOrange,
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppTheme.textWhite : AppTheme.textWhite,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textWhiteMuted,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
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

  Widget _buildForm() {
    if (_selectedType == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.glassWhiteStrong,
          borderRadius: BorderRadius.circular(AppTheme.largeRadius),
          border: Border.all(color: AppTheme.glassBorder),
          boxShadow: [
            BoxShadow(
              color: AppTheme.terracottaRed.withAlpha(42),
              blurRadius: 32,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Datos de la cuenta',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedType == 1
                    ? 'Completa tus datos para buscar profesionales.'
                    : 'Completa tus datos para ofrecer tus servicios.',
                style: const TextStyle(
                  color: AppTheme.textWhiteMuted,
                  height: 1.35,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _fieldLabel('Nombre completo'),
              TextField(
                controller: _fullNameController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'Tu nombre',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              _fieldLabel('Correo electrónico'),
              TextField(
                controller: _emailController,
                enabled: !_isLoading,
                decoration: const InputDecoration(
                  hintText: 'correo@ejemplo.com',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _fieldLabel('Contraseña'),
              TextField(
                controller: _passwordController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Crea una contraseña',
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
              _fieldLabel('Confirmar contraseña'),
              TextField(
                controller: _confirmPasswordController,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  hintText: 'Repite tu contraseña',
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
                _fieldLabel('Categoría de servicio'),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(hintText: 'Selecciona'),
                  dropdownColor: AppTheme.darkBackgroundAlt,
                  style: const TextStyle(color: AppTheme.textWhite),
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
              _fieldLabel('Ciudad'),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(hintText: 'Selecciona'),
                dropdownColor: AppTheme.darkBackgroundAlt,
                style: const TextStyle(color: AppTheme.textWhite),
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
                _fieldLabel('Teléfono'),
                TextField(
                  controller: _phoneController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Número de teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                _fieldLabel('WhatsApp'),
                TextField(
                  controller: _whatsappController,
                  enabled: !_isLoading,
                  decoration: const InputDecoration(
                    hintText: 'Número de WhatsApp',
                    prefixIcon: Icon(Icons.chat),
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ],
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
                      const SizedBox(height: 30),
                      const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Elige cómo quieres usar la app.',
                        style: TextStyle(
                          color: AppTheme.textWhiteMuted,
                          fontSize: 15,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildAccountTypeCard(),
                      _buildForm(),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                Navigator.pop(context);
                              },
                        child: const Text('Ya tengo cuenta'),
                      ),
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
          height: 82,
          width: 82,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.terracottaRed.withAlpha(160),
                AppTheme.warmOrange.withAlpha(112),
              ],
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.warmOrange.withAlpha(58),
                blurRadius: 32,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: const Icon(
            Icons.home_repair_service,
            color: AppTheme.textWhite,
            size: 38,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'ServiColombia',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        const Text(
          'Servicios a tu alcance',
          style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildAccountTypeCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(34),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Selecciona tu tipo de cuenta',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _accountOption(
                    label: 'Cliente',
                    subtitle: 'Busco profesionales',
                    icon: Icons.person,
                    type: 1,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _accountOption(
                    label: 'Profesional',
                    subtitle: 'Ofrezco mis servicios',
                    icon: Icons.work,
                    type: 2,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
