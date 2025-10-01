import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mock_profile_screen.dart';
import 'mock_recurring_transactions_screen.dart';
import 'mock_change_password_screen.dart';
import 'mock_encryption_key_screen.dart';

class MockSettingsScreen extends StatelessWidget {
  const MockSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Account'),
          _buildSettingsTile(
            context,
            icon: Icons.person_outline_rounded,
            title: 'Profile',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.sync_rounded,
            title: 'Recurring Transactions',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MockRecurringTransactionsScreen()));
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Security'),
          _buildSettingsTile(
            context,
            icon: Icons.lock_outline_rounded,
            title: 'Change Password',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MockChangePasswordScreen()));
            },
          ),
          _buildSettingsTile(
            context,
            icon: Icons.vpn_key_outlined,
            title: 'Encryption Key',
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const MockEncryptionKeyScreen()));
            },
          ),
          const SizedBox(height: 20),
          _buildSectionHeader('Application'),
          _buildSettingsTile(
            context,
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            onTap: () {
              // TODO: Implement Notifications Screen
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}

