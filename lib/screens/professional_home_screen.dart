import 'package:flutter/material.dart';

import '../models/professional.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  static final AuthService _authService = AuthService();
  static final ProfessionalService _professionalService = ProfessionalService();

  Future<void> _logout(BuildContext context) async {
    try {
      await _authService.logout();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  String _formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  Widget _buildMessage(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }

  Widget _buildProfile(Professional professional) {
    final description = professional.description.trim().isEmpty
        ? 'Sin descripción por ahora.'
        : professional.description.trim();

    return ListView(
      children: [
        ListTile(
          title: const Text('Nombre'),
          subtitle: Text(professional.name),
        ),
        ListTile(
          title: const Text('Email'),
          subtitle: Text(professional.email),
        ),
        ListTile(
          title: const Text('Categoría'),
          subtitle: Text(professional.category),
        ),
        ListTile(
          title: const Text('Ciudad'),
          subtitle: Text(professional.city),
        ),
        ListTile(title: const Text('Descripción'), subtitle: Text(description)),
        ListTile(
          title: const Text('Teléfono'),
          subtitle: Text(professional.phoneNumber),
        ),
        ListTile(
          title: const Text('WhatsApp'),
          subtitle: Text(professional.whatsappNumber),
        ),
        ListTile(
          title: const Text('Estado de suscripción'),
          subtitle: Text(professional.subscriptionStatus),
        ),
        ListTile(
          title: const Text('Fecha fin de prueba gratis'),
          subtitle: Text(_formatDate(professional.freeTrialEndDate)),
        ),
      ],
    );
  }

  Widget _buildProfessionalProfile() {
    final user = _authService.currentUser;

    if (user == null) {
      return _buildMessage('No hay un usuario logueado.');
    }

    return StreamBuilder<Professional?>(
      stream: _professionalService.getProfessionalById(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return _buildMessage(
            'No se pudo cargar el perfil profesional. Intenta de nuevo más tarde.',
          );
        }

        final professional = snapshot.data;
        if (professional == null) {
          return _buildMessage(
            'No existe un perfil profesional para esta cuenta.',
          );
        }

        return _buildProfile(professional);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profesional')),
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
            Expanded(child: _buildProfessionalProfile()),
          ],
        ),
      ),
    );
  }
}
