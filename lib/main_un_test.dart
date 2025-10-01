import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'screens/mock_main_screen.dart';
import 'services/mock_auth_service.dart';
import 'services/mock_firestore_service.dart';
import 'services/mock_encryption_service.dart'; // Import the new mock service

// This is our temporary main() function for UI testing.
void main() {
  runApp(const UITestApp());
}

class UITestApp extends StatelessWidget {
  const UITestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // We use MultiProvider to provide all of our MOCK services to the app.
    return MultiProvider(
      providers: [
        Provider<MockAuthService>(create: (_) => MockAuthService()),
        Provider<MockFirestoreService>(create: (_) => MockFirestoreService()),
        // --- THE FIX: Provide the new MockEncryptionService ---
        Provider<MockEncryptionService>(create: (_) => MockEncryptionService()),
      ],
      child: MaterialApp(
        title: 'AI Finance Co-Pilot (UI Test)',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        ),
        debugShowCheckedModeBanner: false,
        // The main screen will use our mock services.
        home: MainScreen(), // The constructor is no longer const
      ),
    );
  }
}

// A mock User class is required for the mock to work correctly.
class MockUser extends Mock implements User {
  @override
  String get uid => 'mock_user_id_123';
  @override
  String? get email => 'tester@email.com';
  @override
  String? get displayName => 'Aswin Prasad';
}

