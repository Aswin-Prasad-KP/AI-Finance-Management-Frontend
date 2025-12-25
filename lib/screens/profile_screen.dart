import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart'; // THE CHANGE

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showEditNameDialog(BuildContext context, AuthService authService) {
    final nameController = TextEditingController(text: authService.currentUser?.displayName);
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Edit Display Name', style: GoogleFonts.poppins()),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'New Name'),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(ctx).pop(),
            ),
            ElevatedButton(
              child: const Text('Save'),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  authService.updateDisplayName(nameController.text.trim());
                  Navigator.of(ctx).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // THE CHANGE: Use the real AuthService
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    // The rest of the build method is identical
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.deepPurple.shade100,
            child: Text(
              user?.displayName?.substring(0, 1) ?? 'B',
              style: const TextStyle(fontSize: 40, color: Colors.deepPurple),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user?.displayName ?? 'Buddy',
              style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              user?.email ?? 'buddy@mail.co',
              style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade600),
            ),
          ),
          const SizedBox(height: 40),
          _buildProfileOption(
            context,
            icon: Icons.person_outline,
            title: 'Edit Name',
            onTap: () => _showEditNameDialog(context, authService),
          ),
          // --- REMOVED: Redundant Change Password link ---
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              authService.signOut();
              // Pop all screens until we are back at the start
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent.shade100,
              foregroundColor: Colors.red.shade900,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: GoogleFonts.poppins()),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      onTap: onTap,
    );
  }
}

