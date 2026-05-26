import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';
import '../utils/professional_profile_utils.dart';
import 'category_professionals_screen.dart';
import 'professional_detail_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final TextEditingController _searchController = TextEditingController();
  String? _selectedCity;
  String _searchText = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _logout(BuildContext context) async {
    try {
      await AuthService().logout();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _selectedCity = null;
      _searchText = '';
    });
  }

  void _openProfessionalDetail(Professional professional) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessionalDetailScreen(professional: professional),
      ),
    );
  }

  void _openCategory(String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryProfessionalsScreen(
          category: category,
          initialCity: _selectedCity,
        ),
      ),
    );
  }

  List<Professional> _filterProfessionalsBySearch(
    List<Professional> professionals,
  ) {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return professionals;

    return professionals.where((professional) {
      return professional.name.toLowerCase().contains(query) ||
          professional.category.toLowerCase().contains(query) ||
          professional.city.toLowerCase().contains(query);
    }).toList();
  }

  Widget _buildProfessionalCard(Professional professional) {
    return Card(
      color: AppTheme.glassWhiteStrong,
      margin: EdgeInsets.zero,
      elevation: 8,
      shadowColor: AppTheme.terracottaRed.withAlpha(40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        onTap: () => _openProfessionalDetail(professional),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.terracottaRed.withAlpha(70),
                      borderRadius: BorderRadius.circular(
                        AppTheme.defaultRadius,
                      ),
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: const Icon(
                      Icons.home_repair_service,
                      color: AppTheme.warmOrange,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          professional.name,
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          professional.category,
                          style: const TextStyle(
                            color: AppTheme.warmOrange,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _professionalInfoRow(
                icon: Icons.location_on,
                text: professional.city,
              ),
              const SizedBox(height: 8),
              _professionalInfoRow(
                icon: Icons.chat,
                text: 'WhatsApp: ${professional.whatsappNumber}',
              ),
              const SizedBox(height: 18),
              OutlinedButton(
                onPressed: () => _openProfessionalDetail(professional),
                child: const Text('Ver perfil'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _professionalInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.textWhiteMuted),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppTheme.textWhiteMuted),
          ),
        ),
      ],
    );
  }

  Widget _buildMarketplaceEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Card(
      color: AppTheme.glassWhiteStrong,
      elevation: 8,
      shadowColor: AppTheme.terracottaRed.withAlpha(36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.warmOrange, size: 38),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppTheme.textWhiteMuted),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionText)),
            ],
          ],
        ),
      ),
    );
  }

  IconData _iconForCategory(String category) {
    switch (category) {
      case 'Carpintería':
        return Icons.handyman;
      case 'Plomería':
        return Icons.plumbing;
      case 'Pintura':
        return Icons.format_paint;
      case 'Cerrajería':
        return Icons.lock;
      case 'Electricidad':
        return Icons.electrical_services;
      case 'Aires acondicionados':
        return Icons.ac_unit;
      case 'Jardinería':
        return Icons.yard;
      case 'Mudanzas':
        return Icons.local_shipping;
      case 'Limpieza':
        return Icons.cleaning_services;
      case 'Reformas':
        return Icons.construction;
      default:
        return Icons.home_repair_service;
    }
  }

  List<String> _filteredCategories() {
    final query = _searchText.trim().toLowerCase();
    if (query.isEmpty) return AppConstants.serviceCategories;

    return AppConstants.serviceCategories
        .where((category) => category.toLowerCase().contains(query))
        .toList();
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ubicación',
                style: TextStyle(
                  color: AppTheme.textWhiteMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _selectedCity ?? 'Colombia',
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Encuentra profesionales cerca de ti',
                style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          tooltip: 'Cerrar sesión',
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout),
          color: AppTheme.warmOrange,
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.glassWhiteStrong,
            side: const BorderSide(color: AppTheme.glassBorder),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndCityCard(bool hasFilters) {
    return Card(
      color: AppTheme.glassWhiteStrong,
      elevation: 8,
      shadowColor: AppTheme.terracottaRed.withAlpha(36),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Buscar servicios...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() => _searchText = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('city-${_selectedCity ?? ''}'),
              initialValue: _selectedCity,
              decoration: const InputDecoration(labelText: 'Ciudad'),
              dropdownColor: AppTheme.darkBackgroundAlt,
              style: const TextStyle(color: AppTheme.textWhite),
              items: AppConstants.mainCities
                  .map(
                    (city) => DropdownMenuItem(value: city, child: Text(city)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCity = value);
              },
            ),
            if (hasFilters) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _clearFilters,
                child: const Text('Limpiar filtros'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _filteredCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Servicios Disponibles',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        if (categories.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Text(
              'No encontramos servicios con esa búsqueda.',
              style: TextStyle(color: AppTheme.textWhiteMuted),
              textAlign: TextAlign.center,
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.18,
            ),
            itemBuilder: (context, index) {
              final category = categories[index];

              return InkWell(
                borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                splashColor: AppTheme.warmOrange.withAlpha(36),
                highlightColor: AppTheme.terracottaRed.withAlpha(28),
                onTap: () => _openCategory(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.glassWhiteStrong,
                    borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                    border: Border.all(color: AppTheme.glassBorder),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.terracottaRed.withAlpha(18),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          height: 46,
                          width: 46,
                          decoration: BoxDecoration(
                            color: AppTheme.glassWhiteSoft,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.glassBorder),
                          ),
                          child: Icon(
                            _iconForCategory(category),
                            color: AppTheme.warmOrange,
                            size: 24,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildRecentProfessionalsSection() {
    return StreamBuilder<List<Professional>>(
      stream: _professionalService.getActiveProfessionalsFiltered(
        city: _selectedCity,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.warmOrange),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No se pudieron cargar los profesionales. Intenta de nuevo más tarde.',
                style: TextStyle(color: AppTheme.textWhiteMuted),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final professionals =
            _filterProfessionalsBySearch(
              snapshot.data ?? [],
            ).where(ProfessionalProfileUtils.isProfileComplete).toList()..sort(
              (a, b) => b.registrationDate.compareTo(a.registrationDate),
            );

        final recentProfessionals = professionals.take(3).toList();
        final hasActiveFilters =
            (_selectedCity?.isNotEmpty ?? false) ||
            _searchText.trim().isNotEmpty;

        if (recentProfessionals.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: _buildMarketplaceEmptyState(
              icon: hasActiveFilters ? Icons.search_off : Icons.visibility_off,
              title: hasActiveFilters
                  ? 'No encontramos profesionales'
                  : 'Aún no hay profesionales visibles',
              message: hasActiveFilters
                  ? 'Prueba cambiar la ciudad o limpiar la búsqueda para ver más opciones.'
                  : 'Los profesionales aparecerán aquí cuando completen su perfil y estén disponibles.',
              actionText: hasActiveFilters ? 'Limpiar filtros' : null,
              onAction: hasActiveFilters ? _clearFilters : null,
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: recentProfessionals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final professional = recentProfessionals[index];
            return _buildProfessionalCard(professional);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        (_selectedCity?.isNotEmpty ?? false) || _searchText.trim().isNotEmpty;

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
                const SizedBox(height: 20),
                _buildSearchAndCityCard(hasFilters),
                const SizedBox(height: 24),
                _buildCategoryGrid(),
                const SizedBox(height: 28),
                const Text(
                  'Profesionales recientes',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                _buildRecentProfessionalsSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
