import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      theme: ThemeData(
        // Dark blue primary, orange accent
        primarySwatch: Colors.indigo,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1), // dark blue
          secondary: const Color(0xFFFF9800), // orange
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}
