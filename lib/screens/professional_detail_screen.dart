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
          Text(
            professional.name,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(professional.category),
          Text(professional.city),
          const SizedBox(height: 16),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Descripción'),
            subtitle: Text(description),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Rating'),
            subtitle: Text(professional.rating.toStringAsFixed(1)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Reviews'),
            subtitle: Text(professional.reviewCount.toString()),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Teléfono'),
            subtitle: Text(professional.phoneNumber),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('WhatsApp'),
            subtitle: Text(professional.whatsappNumber),
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
