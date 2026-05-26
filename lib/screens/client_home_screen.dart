import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../constants/category_asset_paths.dart';
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

  Map<String, int> _countCompleteProfessionalsByCategory(
    List<Professional> professionals,
  ) {
    final counts = <String, int>{};

    for (final professional in professionals) {
      if (!ProfessionalProfileUtils.isProfileComplete(professional)) {
        continue;
      }

      counts.update(
        professional.category,
        (currentCount) => currentCount + 1,
        ifAbsent: () => 1,
      );
    }

    return counts;
  }

  String _professionalCountLabel(int count) {
    if (count == 1) return '1 profesional';
    return '$count profesionales';
  }

  Widget _buildMiniChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.warmOrange.withAlpha(26),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.warmOrange.withAlpha(82)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.warmOrange, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.warmOrange,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, String? subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 5),
          Text(
            subtitle,
            style: const TextStyle(color: AppTheme.textWhiteMuted),
          ),
        ],
      ],
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

  Widget _buildProfessionalCard(Professional professional) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(34),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
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
                    height: 58,
                    width: 58,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.terracottaRed.withAlpha(150),
                          AppTheme.warmOrange.withAlpha(105),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warmOrange.withAlpha(34),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.home_repair_service,
                      color: AppTheme.textWhite,
                      size: 28,
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
                        const SizedBox(height: 6),
                        _buildMiniChip(
                          icon: _iconForCategory(professional.category),
                          text: professional.category,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    tooltip: 'Ver perfil',
                    onPressed: () => _openProfessionalDetail(professional),
                    icon: const Icon(Icons.arrow_forward),
                    color: AppTheme.warmOrange,
                    style: IconButton.styleFrom(
                      backgroundColor: AppTheme.glassWhiteSoft,
                      side: const BorderSide(color: AppTheme.glassBorder),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhiteSoft,
                  borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                  border: Border.all(color: AppTheme.glassBorder),
                ),
                child: Column(
                  children: [
                    _professionalInfoRow(
                      icon: Icons.location_on_outlined,
                      text: professional.city,
                    ),
                    const SizedBox(height: 10),
                    _professionalInfoRow(
                      icon: Icons.chat_bubble_outline,
                      text: 'WhatsApp: ${professional.whatsappNumber}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: () => _openProfessionalDetail(professional),
                icon: const Icon(Icons.person_search_outlined),
                label: const Text('Ver perfil'),
              ),
            ],
          ),
        ),
      ),
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(30),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 34,
                      width: 34,
                      decoration: BoxDecoration(
                        color: AppTheme.warmOrange.withAlpha(36),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.glassBorder),
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppTheme.warmOrange,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Flexible(
                      child: Text(
                        _selectedCity ?? 'Colombia',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textWhiteMuted,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Text(
                  '¿Qué servicio necesitas?',
                  style: TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Encuentra profesionales cerca de ti',
                  style: TextStyle(
                    color: AppTheme.textWhiteMuted,
                    fontSize: 15,
                  ),
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
              backgroundColor: AppTheme.glassWhiteSoft,
              side: const BorderSide(color: AppTheme.glassBorder),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndCityCard(bool hasFilters) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(30),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Busca por servicio o profesional',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
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
          const Text(
            'Filtrar por ciudad',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            key: ValueKey('city-${_selectedCity ?? ''}'),
            initialValue: _selectedCity,
            decoration: const InputDecoration(labelText: 'Ciudad'),
            dropdownColor: AppTheme.darkBackgroundAlt,
            style: const TextStyle(color: AppTheme.textWhite),
            items: AppConstants.mainCities
                .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedCity = value);
            },
          ),
          if (hasFilters) ...[
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: _clearFilters,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: const Text('Limpiar filtros'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = _filteredCategories();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSectionHeader(
          title: 'Servicios Disponibles',
          subtitle: 'Explora categorías y encuentra ayuda confiable',
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
          StreamBuilder<List<Professional>>(
            stream: _professionalService.getActiveProfessionalsFiltered(
              city: _selectedCity,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.warmOrange,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'No se pudieron cargar los servicios. Intenta de nuevo más tarde.',
                    style: TextStyle(color: AppTheme.textWhiteMuted),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final countsByCategory = _countCompleteProfessionalsByCategory(
                snapshot.data ?? [],
              );

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final count = countsByCategory[category] ?? 0;

                  return _buildCategoryCard(category: category, count: count);
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildCategoryCard({required String category, required int count}) {
    final imagePath = CategoryAssetPaths.imageForCategory(category);
    final borderRadius = BorderRadius.circular(AppTheme.largeRadius);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        splashColor: AppTheme.warmOrange.withAlpha(36),
        highlightColor: AppTheme.terracottaRed.withAlpha(28),
        onTap: () => _openCategory(category),
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.glassWhiteStrong,
            borderRadius: borderRadius,
            border: Border.all(color: AppTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.terracottaRed.withAlpha(24),
                blurRadius: 22,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (imagePath != null)
                  Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildCategoryFallback(category);
                    },
                  )
                else
                  _buildCategoryFallback(category),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.darkBackground.withAlpha(28),
                        AppTheme.darkBackground.withAlpha(138),
                        AppTheme.darkBackground.withAlpha(226),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.glassWhiteStrong,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.glassBorder),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.warmOrange.withAlpha(30),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _iconForCategory(category),
                      color: AppTheme.warmOrange,
                      size: 25,
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _professionalCountLabel(count),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textWhiteMuted,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFallback(String category) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.terracottaRed.withAlpha(120),
            AppTheme.warmOrange.withAlpha(72),
            AppTheme.darkBackgroundAlt,
          ],
        ),
      ),
      child: Center(
        child: Icon(
          _iconForCategory(category),
          color: AppTheme.textWhite.withAlpha(86),
          size: 58,
        ),
      ),
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
                const SizedBox(height: 26),
                _buildCategoryGrid(),
                const SizedBox(height: 30),
                _buildSectionHeader(
                  title: 'Profesionales recientes',
                  subtitle: 'Perfiles completos disponibles para contactar',
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
