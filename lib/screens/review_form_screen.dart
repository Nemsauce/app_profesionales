import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../constants/app_theme.dart';
import '../services/auth_service.dart';
import '../services/review_service.dart';

class ReviewFormScreen extends StatefulWidget {
  const ReviewFormScreen({
    super.key,
    required this.professionalId,
    required this.professionalName,
  });

  final String professionalId;
  final String professionalName;

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _authService = AuthService();
  final _reviewService = ReviewService();
  final _commentController = TextEditingController();

  double _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<Map<String, dynamic>> _getCurrentUserData(String userId) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
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

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    final user = _authService.currentUser;
    if (user == null) {
      _showSnackBar('Debes iniciar sesión para escribir una reseña.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userData = await _getCurrentUserData(user.uid);
      final clientName = (userData['name'] as String).trim();

      await _reviewService.createReview(
        professionalId: widget.professionalId,
        clientId: user.uid,
        clientName: clientName,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString().replaceFirst('Exception: ', ''));
      setState(() => _isSubmitting = false);
    }
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            tooltip: 'Volver',
            onPressed: _isSubmitting ? null : () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.warmOrange,
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.glassWhiteStrong,
              side: const BorderSide(color: AppTheme.glassBorder),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Escribir reseña',
          style: TextStyle(
            color: AppTheme.textWhite,
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          widget.professionalName,
          style: const TextStyle(color: AppTheme.textWhiteMuted, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRatingSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        final ratingValue = index + 1;
        final isSelected = ratingValue <= _selectedRating;

        return IconButton(
          tooltip: '$ratingValue',
          onPressed: _isSubmitting
              ? null
              : () {
                  setState(() => _selectedRating = ratingValue.toDouble());
                },
          icon: Icon(
            Icons.star_rounded,
            color: isSelected
                ? AppTheme.verifiedGold
                : AppTheme.textWhiteSubtle,
            size: 34,
          ),
        );
      }),
    );
  }

  Widget _fieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
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
            padding: EdgeInsets.fromLTRB(
              AppTheme.screenPadding,
              AppTheme.screenPadding,
              AppTheme.screenPadding,
              AppTheme.screenPadding + keyboardPadding,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 28),
              Card(
                color: AppTheme.glassWhiteStrong,
                elevation: 10,
                shadowColor: AppTheme.terracottaRed.withAlpha(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.largeRadius),
                  side: const BorderSide(color: AppTheme.glassBorder),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _fieldLabel('Calificación'),
                      _buildRatingSelector(),
                      const SizedBox(height: 16),
                      _fieldLabel('Comentario'),
                      TextField(
                        controller: _commentController,
                        enabled: !_isSubmitting,
                        maxLength: 500,
                        minLines: 4,
                        maxLines: 6,
                        style: const TextStyle(color: AppTheme.textWhite),
                        decoration: const InputDecoration(
                          hintText: 'Comentario opcional',
                          counterStyle: TextStyle(
                            color: AppTheme.textWhiteSubtle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitReview,
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.textWhite,
                                ),
                              )
                            : const Text('Enviar reseña'),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
