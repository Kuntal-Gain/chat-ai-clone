import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class ApiService {
  final key = dotenv.env['GEMINI_API_KEY'];

  final String baseUrl =
      "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent"; // Replace with actual API base URL

  Future<Map<String, dynamic>> sendRequest(String prompt) async {
    final url = Uri.parse('$baseUrl?key=$key');

    final Map<String, dynamic> body = {
      "contents": [
        {
          "parts": [
            {"text": prompt}
          ]
        }
      ]
    };

    // Send POST request
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<String> getResponse(String prompt) async {
    try {
      final responseData = await sendRequest(prompt);

      if (responseData['candidates'] != null &&
          responseData['candidates'].isNotEmpty &&
          responseData['candidates'][0]['content'] != null &&
          responseData['candidates'][0]['content']['parts'] != null &&
          responseData['candidates'][0]['content']['parts'].isNotEmpty) {
        return responseData['candidates'][0]['content']['parts'][0]['text'] ??
            'No text available';
      } else {
        return 'No response content available';
      }
    } catch (e) {
      return 'Error: $e';
    }
  }
}
