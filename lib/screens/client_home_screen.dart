import 'package:flutter/material.dart';

import '../constants/app_constants.dart';
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
                    itemCount: professionals.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final professional = professionals[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(professional.name),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ProfessionalDetailScreen(
                                professional: professional,
                              ),
                            ),
                          );
                        },
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Categoría: ${professional.category}'),
                            Text('Ciudad: ${professional.city}'),
                            Text(
                              'Rating: ${professional.rating.toStringAsFixed(1)}',
                            ),
                            Text('Reviews: ${professional.reviewCount}'),
                            Text('WhatsApp: ${professional.whatsappNumber}'),
                          ],
                        ),
                      );
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
