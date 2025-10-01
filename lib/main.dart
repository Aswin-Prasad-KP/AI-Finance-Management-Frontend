import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'models/transaction_model.dart';
import 'services/auth_service.dart';
import 'services/encryption_service.dart';
import 'services/firestore_service.dart';
import 'screens/auth_wrapper.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter and Firebase are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Using a MultiProvider to make services available throughout the app
    return MultiProvider(
      providers: [
        // Provides the authentication logic
        ChangeNotifierProvider<AuthService>(
          create: (_) => AuthService(),
        ),
        // Provides the encryption logic, it's independent
        Provider<EncryptionService>(
          create: (_) => EncryptionService(),
        ),
        // This ProxyProvider creates the FirestoreService once the user logs in.
        // It depends on both the AuthService (to get the user ID) and the
        // EncryptionService.
        ProxyProvider2<AuthService, EncryptionService, FirestoreService?>(
          update: (context, auth, encryption, previousFirestore) {
            final user = auth.currentUser;
            if (user != null) {
              // If a user is logged in, create and provide the FirestoreService
              return FirestoreService(
                userId: user.uid,
                encryptionService: encryption,
              );
            }
            // If no user is logged in, provide null
            return null;
          },
        ),
      ],
      child: MaterialApp(
        title: 'AI Finance Co-Pilot',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF4F6F8),
        ),
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
      ),
    );
  }
}

