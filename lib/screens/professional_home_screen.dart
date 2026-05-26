import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/professional_service.dart';
import '../services/review_service.dart';
import '../utils/professional_profile_utils.dart';
import 'professional_edit_profile_screen.dart';

class ProfessionalHomeScreen extends StatelessWidget {
  const ProfessionalHomeScreen({super.key});

  static final AuthService _authService = AuthService();
  static final ProfessionalService _professionalService = ProfessionalService();
  static final ReviewService _reviewService = ReviewService();

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
        child: Text(
          message,
          style: const TextStyle(color: AppTheme.textWhiteMuted),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildDashboardHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi perfil profesional',
                style: TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Administra cómo te ven los clientes',
                style: TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () => _logout(context),
          icon: const Icon(Icons.logout, size: 18),
          label: const Text('Cerrar sesión'),
          style: OutlinedButton.styleFrom(
            backgroundColor: AppTheme.glassWhiteStrong,
            foregroundColor: AppTheme.warmOrange,
            side: const BorderSide(color: AppTheme.glassBorder),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
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

  Widget _buildProfileRow(String label, String value) {
    final displayValue = value.trim().isEmpty ? 'Sin completar' : value.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
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

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<double>(
      0,
      (totalRating, review) => totalRating + review.rating,
    );

    return total / reviews.length;
  }

  Widget _buildVisibilityStatusCard(Professional professional) {
    final isComplete = ProfessionalProfileUtils.isProfileComplete(professional);
    final completionPercent = ProfessionalProfileUtils.completionPercent(
      professional,
    );
    final missingItems = ProfessionalProfileUtils.missingProfileItems(
      professional,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      color: isComplete
          ? AppTheme.successGreen.withAlpha(38)
          : AppTheme.warningOrange,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: BorderSide(
          color: isComplete ? AppTheme.successGreen : AppTheme.glassBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              isComplete
                  ? 'Tu perfil está visible para clientes.'
                  : 'Tu perfil aún no está visible para clientes.',
              style: TextStyle(
                color: isComplete
                    ? AppTheme.successGreen
                    : AppTheme.warningText,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isComplete
                  ? 'Los clientes pueden encontrarte en el marketplace.'
                  : 'Completa la información faltante para aparecer en el marketplace.',
              style: const TextStyle(color: AppTheme.textWhiteMuted),
            ),
            const SizedBox(height: 12),
            Text(
              'Completitud: $completionPercent%',
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (!isComplete) ...[
              const SizedBox(height: 10),
              ...missingItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        color: AppTheme.warningText,
                        size: 8,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: AppTheme.textWhiteMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfoCard(Professional professional) {
    return _buildInfoCard(
      title: 'Información de contacto',
      children: [
        _buildProfileRow('Teléfono', professional.phoneNumber),
        _buildProfileRow('WhatsApp', professional.whatsappNumber),
        _buildProfileRow('Ciudad', professional.city),
        _buildProfileRow('Categoría', professional.category),
      ],
    );
  }

  Widget _buildReviewStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Icon(
          Icons.star_rounded,
          size: 18,
          color: starValue <= rating.round()
              ? AppTheme.verifiedGold
              : AppTheme.textWhiteSubtle,
        );
      }),
    );
  }

  Widget _buildReviewPreview(Review review) {
    final comment = review.comment.trim();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteSoft,
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  review.clientName,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                review.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: AppTheme.verifiedGold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _buildReviewStars(review.rating),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(color: AppTheme.textWhiteMuted),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSummaryCard(Professional professional) {
    return _buildInfoCard(
      title: 'Reseñas',
      children: [
        StreamBuilder<List<Review>>(
          stream: _reviewService.getReviewsByProfessional(professional.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                !snapshot.hasData) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.warmOrange),
                ),
              );
            }

            if (snapshot.hasError) {
              return const Text(
                'No se pudieron cargar tus reseñas.',
                style: TextStyle(color: AppTheme.textWhiteMuted),
              );
            }

            final reviews = snapshot.data ?? [];
            if (reviews.isEmpty) {
              return const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aún no tienes reseñas.',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Cuando los clientes califiquen tu servicio, aparecerán aquí.',
                    style: TextStyle(color: AppTheme.textWhiteMuted),
                  ),
                ],
              );
            }

            final averageRating = _calculateAverageRating(reviews);
            final latestReviews = reviews.take(2).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildProfileRow(
                  'Rating promedio',
                  averageRating.toStringAsFixed(1),
                ),
                _buildProfileRow('Total de reseñas', reviews.length.toString()),
                const SizedBox(height: 4),
                ...latestReviews.map(_buildReviewPreview),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildVisualProfileHeader(Professional professional) {
    return Card(
      color: AppTheme.glassWhiteStrong,
      elevation: 10,
      margin: const EdgeInsets.only(bottom: 18),
      shadowColor: AppTheme.terracottaRed.withAlpha(48),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        side: const BorderSide(color: AppTheme.glassBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              height: 84,
              width: 84,
              decoration: BoxDecoration(
                color: AppTheme.terracottaRed.withAlpha(72),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.terracottaRed.withAlpha(56),
                    blurRadius: 26,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.home_repair_service,
                color: AppTheme.warmOrange,
                size: 38,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              professional.name,
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              professional.category,
              style: const TextStyle(
                color: AppTheme.warmOrange,
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
        ),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, Professional professional) {
    final hasDescription = professional.description.trim().isNotEmpty;
    final description = hasDescription
        ? professional.description.trim()
        : 'Sin descripción por ahora.';

    return ListView(
      children: [
        _buildVisualProfileHeader(professional),
        _buildVisibilityStatusCard(professional),
        _buildInfoCard(
          title: 'Información básica',
          children: [
            _buildProfileRow('Nombre', professional.name),
            _buildProfileRow('Email', professional.email),
          ],
        ),
        _buildContactInfoCard(professional),
        _buildInfoCard(
          title: 'Descripción',
          children: [_buildProfileRow('Descripción', description)],
        ),
        _buildReviewSummaryCard(professional),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.terracottaRed,
            foregroundColor: AppTheme.textWhite,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
            ),
          ),
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
        const SizedBox(height: 16),
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
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.warmOrange),
          );
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
                _buildDashboardHeader(context),
                const SizedBox(height: 20),
                Expanded(child: _buildProfessionalProfile()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
