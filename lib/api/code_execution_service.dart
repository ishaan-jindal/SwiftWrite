import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CodeExecutionService {
  final String _baseUrl = dotenv.env['codeExecutionBaseURL']!;
  final String _apiKey = dotenv.env['codeExecutionAPI']!;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'X-API-Key': _apiKey,
  };

  Future<bool> isServerHealthy() async {
    try {
      final uri = Uri.parse('$_baseUrl/health');

      final response = await http.get(uri).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Submit code → returns job_id
  Future<String> submitCode({
    required String code,
    required String language,
    List<String>? inputs,
  }) async {
    final uri = Uri.parse('$_baseUrl/submit');

    final response = await http.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'language': language,
        'code': code,
        'inputs': inputs ?? [''],
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      return data['data']['job_id'];
    } else {
      throw Exception(data['error'] ?? 'Failed to submit code');
    }
  }

  /// Get result using job_id
  Future<Map<String, dynamic>> getResult(String jobId) async {
    final uri = Uri.parse('$_baseUrl/result/$jobId');

    final response = await http.get(uri, headers: _headers);

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return data['data'];
    } else {
      throw Exception(data['error'] ?? 'Failed to fetch result');
    }
  }

  /// Convenience method: submit + poll until done
  Future<Map<String, dynamic>> executeCode({
    required String code,
    required String language,
    List<String>? inputs,
    int maxAttempts = 20,
    Duration delay = const Duration(seconds: 1),
  }) async {
    final isHealthy = await isServerHealthy();
    if (!isHealthy) {
      throw Exception('Code execution server is not running');
    }

    final jobId = await submitCode(
      code: code,
      language: language,
      inputs: inputs,
    );

    for (int i = 0; i < maxAttempts; i++) {
      final result = await getResult(jobId);

      final status = result['status'];

      if (status != 'QUEUED' && status != 'RUNNING') {
        return result;
      }

      await Future.delayed(delay);
    }

    throw Exception('Execution timed out');
  }
}
