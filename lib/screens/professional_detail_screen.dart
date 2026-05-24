import 'package:flutter/material.dart';

import '../models/professional.dart';

class ProfessionalDetailScreen extends StatelessWidget {
  const ProfessionalDetailScreen({super.key, required this.professional});

  final Professional professional;

  @override
  Widget build(BuildContext context) {
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
            onPressed: null,
            child: const Text('Contactar por WhatsApp'),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: null, child: const Text('Llamar')),
        ],
      ),
    );
  }
}
