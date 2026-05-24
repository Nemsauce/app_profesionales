import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';
import 'professional_detail_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  static final ProfessionalService _professionalService = ProfessionalService();

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

  @override
  Widget build(BuildContext context) {
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
            Expanded(
              child: StreamBuilder<List<Professional>>(
                stream: _professionalService.getActiveProfessionals(),
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
                    return const Center(
                      child: Text(
                        'No hay profesionales disponibles por ahora.',
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
