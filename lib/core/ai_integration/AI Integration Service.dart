import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pet_health_companion/core/constants/api_constants.dart';

class AIService {
  final http.Client client;

  AIService({required this.client});

  Future<String> analyzeTextSymptoms(String symptoms) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.openAIBaseUrl}/completions'),
        headers: {
          'Authorization': 'Bearer ${ApiConstants.openAIApiKey}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are a veterinary assistant. Analyze these pet symptoms and provide triage recommendation: Monitor, Vet Soon, or Emergency. Respond with only one of these three words.'
            },
            {
              'role': 'user',
              'content': symptoms
            }
          ],
          'max_tokens': 10,
          'temperature': 0.1,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'].trim();
      } else {
        throw Exception('Failed to analyze text symptoms');
      }
    } catch (e) {
      throw Exception('AI service error: $e');
    }
  }

  Future<String> analyzeStoolImage(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.roboflowBaseUrl}/stool-classification'),
      );

      request.headers['Authorization'] = 'Bearer ${ApiConstants.roboflowApiKey}';
      request.files.add(
        await http.MultipartFile.fromPath('image', image.path),
      );

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return _parseStoolAnalysis(data);
      } else {
        throw Exception('Failed to analyze stool image');
      }
    } catch (e) {
      throw Exception('Image analysis error: $e');
    }
  }

  String _parseStoolAnalysis(Map<String, dynamic> data) {
    // Parse Roboflow response and return health classification
    final predictions = data['predictions'] as List;
    if (predictions.isNotEmpty) {
      final topPrediction = predictions[0];
      return topPrediction['class'] ?? 'Unknown';
    }
    return 'Unknown';
  }
}