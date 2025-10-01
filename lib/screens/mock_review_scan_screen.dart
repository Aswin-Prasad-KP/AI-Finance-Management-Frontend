import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../services/mock_ai_service.dart';
import 'mock_add_expense_screen.dart'; // We will reuse the add expense form

class ReviewScanScreen extends StatefulWidget {
  final String imagePath;
  const ReviewScanScreen({super.key, required this.imagePath});

  @override
  State<ReviewScanScreen> createState() => _ReviewScanScreenState();
}

class _ReviewScanScreenState extends State<ReviewScanScreen> {
  // We use a Future to represent the async data extraction
  late Future<Map<String, dynamic>?> _extractionFuture;
  final MockAiService _aiService = MockAiService();

  @override
  void initState() {
    super.initState();
    _extractionFuture = _aiService.extractDataFromImage(File(widget.imagePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Review Scanned Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _extractionFuture,
        builder: (context, snapshot) {
          // While the AI is "processing", show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text("Analyzing your receipt...", style: GoogleFonts.poppins()),
                ],
              ),
            );
          }

          // If extraction fails
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return Center(
              child: Text(
                'Could not extract data from the image. Please try again or enter manually.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final extractedData = snapshot.data!;

          // On success, show the AddExpenseScreen pre-filled with the data
          return AddExpenseScreen(
            // Pass the extracted data to pre-fill the form
            prefilledTitle: extractedData['merchant'] as String?,
            prefilledAmount: extractedData['amount'] as double?,
          );
        },
      ),
    );
  }
}
