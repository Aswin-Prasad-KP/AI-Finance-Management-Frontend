import 'dart:io';

// This class simulates the Python Donut model server.
class MockAiService {
  // In a real app, this would take an image file and send it to the server.
  // Here, we just ignore the file and return fake data after a delay.
  Future<Map<String, dynamic>?> extractDataFromImage(File imageFile) async {
    // Simulate a network call and AI processing time
    await Future.delayed(const Duration(seconds: 2));

    // Return hardcoded, fake extracted data that mimics the server's response
    return {
      "merchant": "Zomato",
      "amount": 280.50,
      "date": "2025-09-27", // In a real app, this would be parsed
    };
  }
}