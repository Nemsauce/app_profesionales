import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';
import 'professional_detail_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final ProfessionalService _professionalService = ProfessionalService();
  String? _selectedCategory;
  String? _selectedCity;

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
    setState(() {
      _selectedCategory = null;
      _selectedCity = null;
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

  Widget _buildProfessionalCard(Professional professional) {
    return Card(
      color: AppTheme.cardBackground,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.10)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _openProfessionalDetail(professional),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                professional.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Categoría: ${professional.category}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text('Ciudad: ${professional.city}'),
              const SizedBox(height: 4),
              Text(
                'Rating: ${professional.rating.toStringAsFixed(1)} (${professional.reviewCount} reviews)',
              ),
              const SizedBox(height: 4),
              Text('WhatsApp: ${professional.whatsappNumber}'),
              const SizedBox(height: 14),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  onPressed: () => _openProfessionalDetail(professional),
                  child: const Text('Ver perfil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasFilters =
        (_selectedCategory?.isNotEmpty ?? false) ||
        (_selectedCity?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(title: const Text('Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () => _logout(context),
              child: const Text('Cerrar sesión'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('category-${_selectedCategory ?? ''}'),
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.serviceCategories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey('city-${_selectedCity ?? ''}'),
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                border: OutlineInputBorder(),
              ),
              items: AppConstants.mainCities
                  .map(
                    (city) => DropdownMenuItem(value: city, child: Text(city)),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedCity = value);
              },
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: hasFilters ? _clearFilters : null,
              child: const Text('Limpiar filtros'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<List<Professional>>(
                stream: _professionalService.getActiveProfessionalsFiltered(
                  category: _selectedCategory,
                  city: _selectedCity,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        'No se pudieron cargar los profesionales. Intenta de nuevo más tarde.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  final professionals = snapshot.data ?? [];

                  if (professionals.isEmpty) {
                    return Center(
                      child: Text(
                        hasFilters
                            ? 'No hay profesionales disponibles con estos filtros.'
                            : 'No hay profesionales disponibles por ahora.',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.only(bottom: 8),
                    itemCount: professionals.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 2),
                    itemBuilder: (context, index) {
                      final professional = professionals[index];
                      return _buildProfessionalCard(professional);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
