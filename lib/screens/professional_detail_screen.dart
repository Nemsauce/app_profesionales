import 'package:flutter/material.dart';

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
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(displayValue),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final professional = widget.professional;
    final description = professional.description.trim().isEmpty
        ? 'Sin descripción por ahora.'
        : professional.description.trim();

    return Scaffold(
      appBar: AppBar(title: Text(professional.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            title: 'Información básica',
            children: [
              Text(
                professional.name,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Categoría', professional.category),
              _buildInfoRow('Ciudad', professional.city),
            ],
          ),
          _buildSection(
            title: 'Descripción',
            children: [_buildInfoRow('Descripción', description)],
          ),
          _buildSection(
            title: 'Reputación',
            children: [
              _buildInfoRow('Rating', professional.rating.toStringAsFixed(1)),
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isContactLoading ? null : _openWhatsApp,
            child: const Text('Contactar por WhatsApp'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _isContactLoading ? null : _callPhone,
            child: const Text('Llamar'),
          ),
        ],
      ),
    );
  }
}
