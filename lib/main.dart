import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'constants/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const OficiosColombiaApp());
}

class OficiosColombiaApp extends StatelessWidget {
  const OficiosColombiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Oficios Colombia',
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}
