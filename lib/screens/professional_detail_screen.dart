import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../models/professional.dart';
import '../models/review.dart';
import '../services/auth_service.dart';
import '../services/contact_service.dart';
import '../services/review_service.dart';

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
  bool _isReviewLoading = false;

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

  Future<Map<String, dynamic>?> _getCurrentUserData() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw Exception('Debes iniciar sesión para escribir una reseña.');
    }

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final data = userDoc.data();

    if (data == null) {
      throw Exception('No se encontró la información del usuario.');
    }

    if (data['role'] != 'client') {
      throw Exception('Solo los clientes pueden escribir reseñas.');
    }

    final name = data['name'];
    if (name is! String || name.trim().isEmpty) {
      throw Exception('No se encontró el nombre del cliente.');
    }

    return data;
  }

  Future<bool> _submitReview({
    required double rating,
    required String comment,
  }) async {
    if (_isReviewLoading) return false;

    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Debes iniciar sesión para escribir una reseña.');
      return false;
    }

    setState(() => _isReviewLoading = true);

    try {
      final userData = await _getCurrentUserData();
      final clientName = (userData?['name'] as String).trim();

      await _reviewService.createReview(
        professionalId: widget.professional.id,
        clientId: user.uid,
        clientName: clientName,
        rating: rating,
        comment: comment,
      );

      if (mounted) {
        _showSnackBar('Reseña enviada correctamente');
      }
      return true;
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      }
      return false;
    } finally {
      if (mounted) {
        setState(() => _isReviewLoading = false);
      }
    }
  }

  void _openReviewDialog() {
    final commentController = TextEditingController();
    double selectedRating = 5;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            final isLoading = _isReviewLoading;

            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppTheme.glassWhiteStrong,
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  border: Border.all(color: AppTheme.glassBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.terracottaRed.withAlpha(42),
                      blurRadius: 32,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Escribir reseña',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Calificación',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final ratingValue = index + 1;
                        final isSelected = ratingValue <= selectedRating;

                        return IconButton(
                          tooltip: '$ratingValue',
                          onPressed: isLoading
                              ? null
                              : () {
                                  setDialogState(() {
                                    selectedRating = ratingValue.toDouble();
                                  });
                                },
                          icon: Icon(
                            Icons.star_rounded,
                            color: isSelected
                                ? AppTheme.verifiedGold
                                : AppTheme.textWhiteSubtle,
                            size: 32,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Comentario',
                      style: TextStyle(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: commentController,
                      enabled: !isLoading,
                      maxLength: 500,
                      maxLines: 4,
                      style: const TextStyle(color: AppTheme.textWhite),
                      decoration: const InputDecoration(
                        hintText: 'Comentario opcional',
                        counterStyle: TextStyle(
                          color: AppTheme.textWhiteSubtle,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isLoading
                                ? null
                                : () => Navigator.of(dialogContext).pop(),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final submitFuture = _submitReview(
                                      rating: selectedRating,
                                      comment: commentController.text,
                                    );
                                    setDialogState(() {});
                                    final reviewCreated = await submitFuture;
                                    if (dialogContext.mounted) {
                                      if (reviewCreated) {
                                        Navigator.of(dialogContext).pop();
                                      } else {
                                        setDialogState(() {});
                                      }
                                    }
                                  },
                            child: isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppTheme.textWhite,
                                    ),
                                  )
                                : const Text('Enviar reseña'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(commentController.dispose);
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

  String _formatReviewDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildReviewStars(review.rating)),
              Text(
                _formatReviewDate(review.createdAt),
                style: const TextStyle(
                  color: AppTheme.textWhiteSubtle,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.clientName,
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              comment,
              style: const TextStyle(color: AppTheme.textWhiteMuted),
            ),
          ],
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

            return OutlinedButton(
              onPressed: _isReviewLoading ? null : _openReviewDialog,
              child: const Text('Escribir reseña'),
            );
          },
        );
      },
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

  Widget _buildReviewsSummary(Professional professional) {
    return StreamBuilder<List<Review>>(
      stream: _reviewService.getReviewsByProfessional(professional.id),
      builder: (context, snapshot) {
        final fallbackRating = professional.rating;
        final fallbackReviewCount = professional.reviewCount;

        Widget buildContent({
          required double rating,
          required int reviewCount,
          List<Review> reviews = const [],
          String? message,
          bool showLoading = false,
        }) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoRow('Rating', rating.toStringAsFixed(1)),
              _buildInfoRow('Reviews', reviewCount.toString()),
              const SizedBox(height: 12),
              _buildReviewAction(),
              if (showLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.warmOrange,
                    ),
                  ),
                ),
              if (message != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    message,
                    style: const TextStyle(color: AppTheme.textWhiteMuted),
                  ),
                ),
              ...reviews.take(5).map(_buildReviewCard),
            ],
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return buildContent(
            rating: fallbackRating,
            reviewCount: fallbackReviewCount,
            showLoading: true,
          );
        }

        if (snapshot.hasError) {
          return buildContent(
            rating: fallbackRating,
            reviewCount: fallbackReviewCount,
            message: 'No se pudieron cargar las reseñas.',
          );
        }

        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return buildContent(
            rating: fallbackRating,
            reviewCount: fallbackReviewCount,
            message: 'Aún no hay reseñas para este profesional.',
          );
        }

        return buildContent(
          rating: _calculateAverageRating(reviews),
          reviewCount: reviews.length,
          reviews: reviews,
        );
      },
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
                children: [_buildReviewsSummary(professional)],
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
