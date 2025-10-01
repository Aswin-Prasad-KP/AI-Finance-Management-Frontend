import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/encryption_service.dart';
import './profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;
  String? _feedbackMessage;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _loadSecretKey();
  }

  Future<void> _loadSecretKey() async {
    final encryptionService = Provider.of<EncryptionService>(context, listen: false);
    final key = await encryptionService.getSecretKey();
    if (key != null) {
      _secretKeyController.text = key;
    }
  }

  Future<void> _saveSecretKey() async {
    setState(() {
      _isLoading = true;
      _feedbackMessage = null;
    });

    final encryptionService = Provider.of<EncryptionService>(context, listen: false);
    final success = await encryptionService.setSecretKey(_secretKeyController.text);

    setState(() {
      _isLoading = false;
      if (success) {
        _feedbackMessage = 'Secret key saved successfully! Please restart the app.';
        _feedbackColor = Colors.green;
      } else {
        _feedbackMessage = 'Failed to save key. It must be 32 characters long.';
        _feedbackColor = Colors.red;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userEmail = authService.currentUser?.email ?? 'No email';

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Account'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Profile'),
              subtitle: Text(userEmail),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Security'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Secret Encryption Key', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'This key encrypts your data. It is stored ONLY on your device. If you lose it, your data cannot be recovered. Must be 32 characters.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _secretKeyController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Enter your 32-character secret key',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(_feedbackMessage!, style: TextStyle(color: _feedbackColor)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveSecretKey,
                      child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 3)) : const Text('Save Key'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('App'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                authService.signOut();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.8),
      ),
    );
  }
}

