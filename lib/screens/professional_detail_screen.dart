import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../services/contact_service.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  const ProfessionalDetailScreen({super.key, required this.professional});

  final Professional professional;

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  final _contactService = ContactService();
  bool _isContactLoading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openWhatsApp() async {
    if (_isContactLoading) return;

    setState(() => _isContactLoading = true);

    try {
      await _contactService.openWhatsApp(widget.professional.whatsappNumber);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isContactLoading = false);
      }
    }
  }

  Future<void> _callPhone() async {
    if (_isContactLoading) return;

    setState(() => _isContactLoading = true);

    try {
      await _contactService.callPhone(widget.professional.phoneNumber);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _isContactLoading = false);
      }
    }
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: AppTheme.glassWhiteStrong,
      elevation: 8,
      margin: const EdgeInsets.only(bottom: 14),
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
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Sin completar' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            displayValue,
            style: const TextStyle(color: AppTheme.textWhiteMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Professional professional) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Volver',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.warmOrange,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.glassWhiteStrong,
              side: const BorderSide(color: AppTheme.glassBorder),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Center(
          child: Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: AppTheme.terracottaRed.withAlpha(72),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.terracottaRed.withAlpha(64),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_repair_service,
              color: AppTheme.warmOrange,
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          professional.name,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          professional.category,
          style: const TextStyle(
            color: AppTheme.warmOrange,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: AppTheme.textWhiteMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              professional.city,
              style: const TextStyle(color: AppTheme.textWhiteMuted),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final professional = widget.professional;
    final description = professional.description.trim().isEmpty
        ? 'Sin descripción por ahora.'
        : professional.description.trim();

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
          child: ListView(
            padding: const EdgeInsets.all(AppTheme.screenPadding),
            children: [
              _buildHeader(professional),
              const SizedBox(height: 28),
              _buildSection(
                title: 'Descripción',
                children: [_buildInfoRow('Descripción', description)],
              ),
              _buildSection(
                title: 'Reputación',
                children: [
                  _buildInfoRow(
                    'Rating',
                    professional.rating.toStringAsFixed(1),
                  ),
                  _buildInfoRow('Reviews', professional.reviewCount.toString()),
                ],
              ),
              _buildSection(
                title: 'Contacto',
                children: [
                  _buildInfoRow('Teléfono', professional.phoneNumber),
                  _buildInfoRow('WhatsApp', professional.whatsappNumber),
                ],
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.successGreen,
                  foregroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                  ),
                ),
                onPressed: _isContactLoading ? null : _openWhatsApp,
                child: const Text('Contactar por WhatsApp'),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: _isContactLoading ? null : _callPhone,
                child: const Text('Llamar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
