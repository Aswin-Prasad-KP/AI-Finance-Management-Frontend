import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'mock_add_expense_screen.dart';
import 'mock_camera_screen.dart';
// We need image_picker for the upload functionality
import 'package:image_picker/image_picker.dart';
import 'mock_review_scan_screen.dart';

class AddTransactionModal extends StatelessWidget {
  const AddTransactionModal({super.key});

  Future<void> _pickImageAndNavigate(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    // We use a try-catch block in case the user cancels the image picking
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null && context.mounted) {
        // Close the modal first
        Navigator.of(context).pop();
        // Then navigate to the review screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (ctx) => ReviewScanScreen(imagePath: pickedFile.path),
          ),
        );
      }
    } catch (e) {
      // User likely cancelled the action, do nothing.
      print('Image picking cancelled: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Add a New Transaction', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _buildOptionTile(
            context,
            icon: Icons.edit_note,
            title: 'Manual Entry',
            subtitle: 'Enter details by hand',
            onTap: () {
              Navigator.of(context).pop(); // Close this modal
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (_) => const AddExpenseScreen(),
              );
            },
          ),
          const Divider(),
          _buildOptionTile(
            context,
            icon: Icons.camera_alt_outlined,
            title: 'Scan Receipt',
            subtitle: 'Use your camera to capture a bill',
            onTap: () => _pickImageAndNavigate(context, ImageSource.camera),
          ),
          const Divider(),
          _buildOptionTile(
            context,
            icon: Icons.upload_file_outlined,
            title: 'Upload Image',
            subtitle: 'Pick a receipt from your gallery',
            onTap: () => _pickImageAndNavigate(context, ImageSource.gallery),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, size: 30, color: Theme.of(context).primaryColor),
      title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: GoogleFonts.poppins()),
      onTap: onTap,
    );
  }
}
