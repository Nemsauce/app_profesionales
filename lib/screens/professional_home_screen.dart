import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';
import 'professional_edit_profile_screen.dart';

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

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: AppTheme.cardBackground,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: AppTheme.primaryBlue.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Sin completar' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(displayValue),
        ],
      ),
    );
  }

  Widget _buildNotice(String message) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppTheme.warningOrange,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(padding: const EdgeInsets.all(14), child: Text(message)),
    );
  }

  Widget _buildProfile(BuildContext context, Professional professional) {
    final hasDescription = professional.description.trim().isNotEmpty;
    final hasPhoneNumber = professional.phoneNumber.trim().isNotEmpty;
    final hasWhatsappNumber = professional.whatsappNumber.trim().isNotEmpty;
    final description = hasDescription
        ? professional.description.trim()
        : 'Sin descripción por ahora.';

    return ListView(
      children: [
        if (!hasDescription)
          _buildNotice(
            'Agrega una descripción para que los clientes entiendan mejor tus servicios.',
          ),
        if (!hasPhoneNumber || !hasWhatsappNumber)
          _buildNotice(
            'Agrega tu teléfono y WhatsApp para que los clientes puedan contactarte.',
          ),
        _buildInfoCard(
          title: 'Información básica',
          children: [
            _buildProfileRow('Nombre', professional.name),
            _buildProfileRow('Email', professional.email),
            _buildProfileRow('Categoría', professional.category),
            _buildProfileRow('Ciudad', professional.city),
          ],
        ),
        _buildInfoCard(
          title: 'Descripción',
          children: [_buildProfileRow('Descripción', description)],
        ),
        _buildInfoCard(
          title: 'Contacto',
          children: [
            _buildProfileRow('Teléfono', professional.phoneNumber),
            _buildProfileRow('WhatsApp', professional.whatsappNumber),
          ],
        ),
        _buildInfoCard(
          title: 'Suscripción',
          children: [
            _buildProfileRow(
              'Estado de suscripción',
              professional.subscriptionStatus,
            ),
            _buildProfileRow(
              'Fecha fin de prueba gratis',
              _formatDate(professional.freeTrialEndDate),
            ),
          ],
        ),
        const SizedBox(height: 18),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ProfessionalEditProfileScreen(professional: professional),
              ),
            );
          },
          child: const Text('Editar perfil'),
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

        return _buildProfile(context, professional);
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
