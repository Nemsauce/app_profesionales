import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/professional_service.dart';
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.warmOrange,
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.glassWhiteStrong,
            side: const BorderSide(color: AppTheme.glassBorder),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          height: 56,
          width: 56,
          decoration: BoxDecoration(
            color: AppTheme.glassWhiteStrong,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.glassBorder),
            boxShadow: [
              BoxShadow(
                color: AppTheme.terracottaRed.withAlpha(40),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(
            _iconForCategory(widget.category),
            color: AppTheme.warmOrange,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category,
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Profesionales disponibles',
                style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
              ),
            ],
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
            const Text(
              'Buscar y filtrar',
              style: TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
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
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.glassBorder),
                    ),
                    child: Icon(
                      _iconForCategory(professional.category),
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
                icon: Icons.star,
                text:
                    '${professional.rating.toStringAsFixed(1)} (${professional.reviewCount} reviews)',
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

        final professionals = _filterProfessionalsBySearch(snapshot.data ?? []);

        if (professionals.isEmpty) {
          return Center(
            child: Text(
              hasFilters
                  ? 'No hay profesionales disponibles con estos filtros.'
                  : 'No hay profesionales disponibles en esta categoría por ahora.',
              style: const TextStyle(color: AppTheme.textWhiteMuted),
              textAlign: TextAlign.center,
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
