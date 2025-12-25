import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiService {
  // Key to access the stored IP address
  static const _serverIpKey = 'ai_server_ip';

  /// Helper method to get the base URL dynamically from SharedPreferences.
  Future<String?> _getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    // Returns the saved IP or null if it doesn't exist.
    return prefs.getString(_serverIpKey);
  }

  /// Extracts transaction data from an image file by calling the Python server.
  Future<Map<String, dynamic>?> extractDataFromImage(File imageFile) async {
    final baseUrl = await _getBaseUrl();
    // --- THE FIX: Check if the URL is configured before proceeding ---
    if (baseUrl == null || baseUrl.isEmpty) {
      print('AI Server IP not configured. Please set it in the settings.');
      // Return a map with an error key that the UI can check for.
      return {"error": "AI Server IP not configured. Please set it via the Settings page."};
    }

    try {
      final uri = Uri.parse('$baseUrl/extract');
      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // This must match the key in your Flask app
          imageFile.path,
          filename: basename(imageFile.path),
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        return json.decode(responseBody) as Map<String, dynamic>;
      } else {
        final errorBody = await response.stream.bytesToString();
        print('Server Error: ${response.statusCode}');
        print('Server Response: $errorBody');
        return {"error": "Server Error: ${response.statusCode}. Check server logs."};
      }
    } catch (e) {
      print('Network Error connecting to AI service: $e');
      return {"error": "Network error. Is the server running and the IP correct?"};
    }
  }
}