import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/professional_service.dart';
import '../utils/professional_profile_utils.dart';
import 'professional_detail_screen.dart';

class CategoryProfessionalsScreen extends StatefulWidget {
  final String category;
  final String? initialCity;

  const CategoryProfessionalsScreen({
    super.key,
    required this.category,
    this.initialCity,
  });

  @override
  State<CategoryProfessionalsScreen> createState() =>
      _CategoryProfessionalsScreenState();
}

class _CategoryProfessionalsScreenState
    extends State<CategoryProfessionalsScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  final TextEditingController _searchController = TextEditingController();

  String? _selectedCity;
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    if (AppConstants.mainCities.contains(widget.initialCity)) {
      _selectedCity = widget.initialCity;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          IconButton(
            tooltip: 'Volver',
            onPressed: () => Navigator.pop(context),
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
            child: Icon(
              _iconForCategory(widget.category),
              color: AppTheme.textWhite,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Profesionales disponibles',
                  style: TextStyle(
                    color: AppTheme.textWhiteMuted,
                    fontSize: 15,
                  ),
                ),
              ],
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
            'Busca dentro de esta categoría',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Buscar profesionales...',
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

  Widget _buildCategoryChip(String category) {
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
          Icon(
            _iconForCategory(category),
            color: AppTheme.warmOrange,
            size: 15,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              category,
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
                    child: Icon(
                      _iconForCategory(professional.category),
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
                        _buildCategoryChip(professional.category),
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

  Widget _buildCategoryEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Container(
      padding: const EdgeInsets.all(22),
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: AppTheme.warmOrange.withAlpha(28),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: Icon(icon, color: AppTheme.warmOrange, size: 30),
          ),
          const SizedBox(height: 14),
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
            OutlinedButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.filter_alt_off_outlined),
              label: Text(actionText),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProfessionalsList(bool hasFilters) {
    return StreamBuilder<List<Professional>>(
      stream: _professionalService.getActiveProfessionalsFiltered(
        category: widget.category,
        city: _selectedCity,
      ),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.warmOrange),
          );
        }

        if (snapshot.hasError) {
          return const Center(
            child: Text(
              'No se pudieron cargar los profesionales. Intenta de nuevo más tarde.',
              style: TextStyle(color: AppTheme.textWhiteMuted),
              textAlign: TextAlign.center,
            ),
          );
        }

        final professionals = _filterProfessionalsBySearch(
          snapshot.data ?? [],
        ).where(ProfessionalProfileUtils.isProfileComplete).toList();

        if (professionals.isEmpty) {
          return Center(
            child: _buildCategoryEmptyState(
              icon: hasFilters ? Icons.search_off : Icons.category,
              title: hasFilters
                  ? 'No encontramos resultados'
                  : 'Aún no hay profesionales en esta categoría',
              message: hasFilters
                  ? 'Prueba limpiar los filtros o cambiar la ciudad.'
                  : 'Cuando haya profesionales con perfil completo en esta categoría, aparecerán aquí.',
              actionText: hasFilters ? 'Limpiar filtros' : null,
              onAction: hasFilters ? _clearFilters : null,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 8),
          itemCount: professionals.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final professional = professionals[index];
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
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildSearchAndCityCard(hasFilters),
                const SizedBox(height: 18),
                Expanded(child: _buildProfessionalsList(hasFilters)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
