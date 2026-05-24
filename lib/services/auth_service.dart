import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import '../models/professional.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> getCurrentUserRole() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) return null;

      final role = userDoc.data()?['role'];

      if (role == 'client' || role == 'professional') {
        return role as String;
      }

      return null;
    } on FirebaseException catch (e) {
      throw Exception(
        'No se pudo obtener el rol del usuario: ${e.message ?? e.code}',
      );
    } catch (e) {
      throw Exception('No se pudo obtener el rol del usuario.');
    }
  }

  Future<void> login({required String email, required String password}) async {
    final normalizedEmail = email.trim().toLowerCase();
    try {
      await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      throw Exception('Error inesperado durante el login');
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Error inesperado durante el logout');
    }
  }

  Future<void> registerClient({
    required String name,
    required String email,
    required String password,
    required String city,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final now = DateTime.now();
    User? user;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      user = userCredential.user;
      if (user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      final uid = user.uid;

      final batch = _firestore.batch();

      // users/{uid}
      batch.set(_firestore.collection('users').doc(uid), {
        'id': uid,
        'name': name,
        'email': normalizedEmail,
        'role': 'client',
        'createdAt': Timestamp.fromDate(now),
      });

      // clients/{uid}
      final client = Client(
        id: uid,
        name: name,
        photoUrl: '',
        email: normalizedEmail,
        city: city,
      );
      batch.set(_firestore.collection('clients').doc(uid), client.toJson());

      await batch.commit();
    } on FirebaseAuthException catch (e) {
      await _deleteCreatedUserIfNeeded(user);
      throw Exception(_handleAuthException(e));
    } catch (e) {
      await _deleteCreatedUserIfNeeded(user);
      throw Exception(
        'Falló el registro del cliente. Por favor, intenta de nuevo.',
      );
    }
  }

  Future<void> registerProfessional({
    required String name,
    required String email,
    required String password,
    required String category,
    required String city,
    required String phoneNumber,
    required String whatsappNumber,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final now = DateTime.now();
    User? user;
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      user = userCredential.user;
      if (user == null) {
        throw Exception('No se pudo crear el usuario');
      }

      final uid = user.uid;
      final trialEnd = now.add(const Duration(days: 90));

      final batch = _firestore.batch();

      // users/{uid}
      batch.set(_firestore.collection('users').doc(uid), {
        'id': uid,
        'name': name,
        'email': normalizedEmail,
        'role': 'professional',
        'createdAt': Timestamp.fromDate(now),
      });

      // professionals/{uid}
      final professional = Professional(
        id: uid,
        name: name,
        email: normalizedEmail,
        photoUrl: '',
        description: '',
        category: category,
        city: city,
        phoneNumber: phoneNumber,
        whatsappNumber: whatsappNumber,
        portfolioPhotos: [],
        rating: 0.0,
        reviewCount: 0,
        registrationDate: now,
        freeTrialStartDate: now,
        freeTrialEndDate: trialEnd,
        subscriptionStatus: 'trial',
        subscriptionActive: true,
      );
      batch.set(
        _firestore.collection('professionals').doc(uid),
        professional.toJson(),
      );

      await batch.commit();
    } on FirebaseAuthException catch (e) {
      await _deleteCreatedUserIfNeeded(user);
      throw Exception(_handleAuthException(e));
    } catch (e) {
      await _deleteCreatedUserIfNeeded(user);
      throw Exception(
        'Falló el registro del profesional. Por favor, intenta de nuevo.',
      );
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'El correo electrónico ya está en uso.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'user-not-found':
        return 'No se encontró un usuario con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Credenciales inválidas.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }

  Future<void> _deleteCreatedUserIfNeeded(User? user) async {
    if (user == null) return;
    try {
      await user.delete();
    } catch (_) {
      // ignore errors to avoid masking the original error
    }
  }
}
