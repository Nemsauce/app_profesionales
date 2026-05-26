import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/contact_service.dart';
import '../services/review_service.dart';
import '../utils/professional_profile_utils.dart';
import 'review_form_screen.dart';

class ProfessionalDetailScreen extends StatefulWidget {
  const ProfessionalDetailScreen({super.key, required this.professional});

  final Professional professional;

  @override
  State<ProfessionalDetailScreen> createState() =>
      _ProfessionalDetailScreenState();
}

class _ProfessionalDetailScreenState extends State<ProfessionalDetailScreen> {
  final _contactService = ContactService();
  final _reviewService = ReviewService();
  final _authService = AuthService();
  late final Future<String?> _currentUserRoleFuture;
  bool _isContactLoading = false;

  @override
  void initState() {
    super.initState();
    _currentUserRoleFuture = _getCurrentUserRoleForReviews();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<String?> _getCurrentUserRoleForReviews() async {
    final user = _authService.currentUser;
    if (user == null) return null;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final role = userDoc.data()?['role'];

    return role is String ? role : null;
  }

  Future<void> _openReviewForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewFormScreen(
          professionalId: widget.professional.id,
          professionalName: widget.professional.name,
        ),
      ),
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reseña enviada correctamente')),
      );
    }
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

  String _formatReviewDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  double _calculateAverageRating(List<Review> reviews) {
    if (reviews.isEmpty) return 0;

    final total = reviews.fold<double>(
      0,
      (totalRating, review) => totalRating + review.rating,
    );

    return total / reviews.length;
  }

  Widget _buildGlassCard({
    required List<Widget> children,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    EdgeInsetsGeometry margin = const EdgeInsets.only(bottom: 16),
  }) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteStrong,
        borderRadius: BorderRadius.circular(AppTheme.largeRadius),
        border: Border.all(color: AppTheme.glassBorder),
        boxShadow: [
          BoxShadow(
            color: AppTheme.terracottaRed.withAlpha(34),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textWhite,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTopHeader() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Volver',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
          color: AppTheme.textWhite,
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.glassWhiteStrong,
            side: const BorderSide(color: AppTheme.glassBorder),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Text(
            'Perfil Profesional',
            style: TextStyle(
              color: AppTheme.textWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    Color color = AppTheme.warmOrange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(32),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withAlpha(120)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStars(double rating, {double size = 18}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        return Icon(
          Icons.star_rounded,
          size: size,
          color: starValue <= rating.round()
              ? AppTheme.verifiedGold
              : AppTheme.textWhiteSubtle,
        );
      }),
    );
  }

  Widget _buildMainProfileCard({
    required Professional professional,
    required List<Review> reviews,
    required bool reviewsLoading,
    required bool reviewsError,
  }) {
    final isProfileComplete = ProfessionalProfileUtils.isProfileComplete(
      professional,
    );
    final averageRating = _calculateAverageRating(reviews);

    return _buildGlassCard(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Container(
            height: 104,
            width: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.terracottaRed.withAlpha(180),
                  AppTheme.warmOrange.withAlpha(150),
                ],
              ),
              border: Border.all(color: AppTheme.glassBorder),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.warmOrange.withAlpha(58),
                  blurRadius: 32,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            child: const Icon(
              Icons.home_repair_service,
              color: AppTheme.textWhite,
              size: 46,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          professional.name,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          professional.category,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.warmOrange,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_on,
              color: AppTheme.textWhiteMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                professional.city,
                style: const TextStyle(color: AppTheme.textWhiteMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            if (isProfileComplete)
              _buildBadge(
                icon: Icons.check_circle,
                label: 'Perfil completo',
                color: AppTheme.successGreen,
              ),
            if (reviews.isNotEmpty)
              _buildBadge(
                icon: Icons.star_rounded,
                label:
                    '${averageRating.toStringAsFixed(1)} (${reviews.length} reseñas)',
                color: AppTheme.verifiedGold,
              )
            else
              _buildBadge(
                icon: Icons.star_border_rounded,
                label: reviewsLoading
                    ? 'Cargando reseñas'
                    : reviewsError
                    ? 'Reseñas no disponibles'
                    : 'Sin reseñas todavía',
                color: AppTheme.warmOrange,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildContactActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: AppTheme.textWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
              ),
            ),
            onPressed: _isContactLoading ? null : _openWhatsApp,
            icon: _isContactLoading
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      color: AppTheme.textWhite,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.chat_bubble_outline),
            label: const Text('Contactar'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textWhite,
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: AppTheme.glassBorder),
              backgroundColor: AppTheme.glassWhiteSoft,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
              ),
            ),
            onPressed: _isContactLoading ? null : _callPhone,
            icon: const Icon(Icons.call_outlined),
            label: const Text('Llamar'),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteSoft,
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.warmOrange, size: 22),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: AppTheme.textWhiteMuted),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFutureMetricsSection() {
    return _buildGlassCard(
      children: [
        _buildSectionTitle('Métricas'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.35,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildMetricTile(
              icon: Icons.work_outline,
              label: 'Trabajos',
              value: 'Próximamente',
            ),
            _buildMetricTile(
              icon: Icons.verified_outlined,
              label: 'Verificación',
              value: 'Pendiente',
            ),
            _buildMetricTile(
              icon: Icons.favorite_border,
              label: 'Satisfacción',
              value: 'Aún no disponible',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    Color color = AppTheme.warmOrange,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteSoft,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textWhiteMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Professional professional) {
    final description = professional.description.trim().isEmpty
        ? 'Sin descripción por ahora.'
        : professional.description.trim();

    return _buildGlassCard(
      children: [
        _buildSectionTitle('Sobre mí'),
        const SizedBox(height: 12),
        Text(
          description,
          style: const TextStyle(color: AppTheme.textWhiteMuted, height: 1.45),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildInfoChip(
              icon: Icons.home_repair_service_outlined,
              label: professional.category,
            ),
            _buildInfoChip(
              icon: Icons.location_on_outlined,
              label: professional.city,
            ),
            _buildInfoChip(
              icon: Icons.chat_bubble_outline,
              label: 'Contacto disponible',
              color: AppTheme.successGreen,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPortfolioSection(Professional professional) {
    final photos = professional.portfolioPhotos
        .map((photo) => photo.trim())
        .where((photo) => photo.isNotEmpty)
        .toList();

    return _buildGlassCard(
      children: [
        _buildSectionTitle('Portafolio'),
        const SizedBox(height: 14),
        if (photos.isEmpty)
          const Text(
            'Este profesional aún no ha agregado fotos de trabajos.',
            style: TextStyle(color: AppTheme.textWhiteMuted),
          )
        else
          GridView.builder(
            itemCount: photos.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
                child: Image.network(
                  photos[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.glassWhiteSoft,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: AppTheme.textWhiteMuted,
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildReviewCard(Review review) {
    final comment = review.comment.trim();

    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.glassWhiteSoft,
        borderRadius: BorderRadius.circular(AppTheme.defaultRadius),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 42,
            width: 42,
            decoration: BoxDecoration(
              color: AppTheme.warmOrange.withAlpha(42),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.glassBorder),
            ),
            child: const Icon(
              Icons.person_outline,
              color: AppTheme.warmOrange,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                    const SizedBox(width: 8),
                    Text(
                      _formatReviewDate(review.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textWhiteSubtle,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildReviewStars(review.rating, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      review.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: AppTheme.verifiedGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (comment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    comment,
                    style: const TextStyle(color: AppTheme.textWhiteMuted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewAction() {
    return FutureBuilder<String?>(
      future: _currentUserRoleFuture,
      builder: (context, roleSnapshot) {
        final user = _authService.currentUser;

        if (roleSnapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox.shrink();
        }

        if (roleSnapshot.hasError ||
            user == null ||
            roleSnapshot.data != 'client') {
          return const SizedBox.shrink();
        }

        return StreamBuilder<Review?>(
          stream: _reviewService.getReviewByClientAndProfessional(
            clientId: user.uid,
            professionalId: widget.professional.id,
          ),
          builder: (context, reviewSnapshot) {
            if (reviewSnapshot.connectionState == ConnectionState.waiting &&
                !reviewSnapshot.hasData) {
              return const SizedBox.shrink();
            }

            if (reviewSnapshot.hasError) {
              return const SizedBox.shrink();
            }

            if (reviewSnapshot.data != null) {
              return const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  'Ya enviaste una reseña para este profesional.',
                  style: TextStyle(color: AppTheme.textWhiteMuted),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: OutlinedButton.icon(
                onPressed: _openReviewForm,
                icon: const Icon(Icons.rate_review_outlined),
                label: const Text('Escribir reseña'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReviewsSection({
    required List<Review> reviews,
    required bool isLoading,
    required bool hasError,
  }) {
    return _buildGlassCard(
      children: [
        _buildSectionTitle('Reseñas recientes'),
        _buildReviewAction(),
        if (isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 18),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.warmOrange),
            ),
          )
        else if (hasError)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
              'No se pudieron cargar las reseñas.',
              style: TextStyle(color: AppTheme.textWhiteMuted),
            ),
          )
        else if (reviews.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 14),
            child: Text(
              'Aún no hay reseñas para este profesional.',
              style: TextStyle(color: AppTheme.textWhiteMuted),
            ),
          )
        else
          ...reviews.take(5).map(_buildReviewCard),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final professional = widget.professional;

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
          child: StreamBuilder<List<Review>>(
            stream: _reviewService.getReviewsByProfessional(professional.id),
            builder: (context, reviewSnapshot) {
              final reviews = reviewSnapshot.data ?? [];
              final reviewsLoading =
                  reviewSnapshot.connectionState == ConnectionState.waiting &&
                  !reviewSnapshot.hasData;
              final reviewsError = reviewSnapshot.hasError;

              return ListView(
                padding: const EdgeInsets.all(AppTheme.screenPadding),
                children: [
                  _buildTopHeader(),
                  const SizedBox(height: 18),
                  _buildMainProfileCard(
                    professional: professional,
                    reviews: reviews,
                    reviewsLoading: reviewsLoading,
                    reviewsError: reviewsError,
                  ),
                  _buildContactActions(),
                  const SizedBox(height: 16),
                  _buildFutureMetricsSection(),
                  _buildAboutSection(professional),
                  _buildPortfolioSection(professional),
                  _buildReviewsSection(
                    reviews: reviews,
                    isLoading: reviewsLoading,
                    hasError: reviewsError,
                  ),
                  const SizedBox(height: 16),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
