import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

// This class simulates the Firebase Auth service for UI testing.
class MockAuthService {
  final _authStateController = StreamController<User?>.broadcast();
  User? _currentUser = MockUser(); // Start with a logged-in mock user

  Stream<User?> get authStateChanges => _authStateController.stream;
  User? get currentUser => _currentUser;

  MockAuthService() {
    _authStateController.add(_currentUser);
  }

  // --- NEW MOCK METHODS ---
  Future<void> updateDisplayName(String newName) async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));
    if (_currentUser != null) {
      _currentUser = MockUser(displayName: newName, email: _currentUser!.email);
      // Notify listeners that the user object has changed
      _authStateController.add(_currentUser);
    }
  }

  Future<bool> changePassword(String currentPassword, String newPassword) async {
    // In a mock, we can just pretend it always succeeds after a delay
    await Future.delayed(const Duration(seconds: 1));
    print('Password changed successfully (mock)');
    return true;
  }
  // --- END NEW MOCK METHODS ---

  Future<void> signOut() async {
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}

// A mock User class is required for the mock to work correctly.
class MockUser extends Mock implements User {
  @override
  final String uid;
  @override
  final String? email;
  @override
  final String? displayName;

  MockUser({
    this.uid = 'mock_user_id_123',
    this.email = 'tester@email.com',
    this.displayName = 'Aswin Prasad',
  });
}

