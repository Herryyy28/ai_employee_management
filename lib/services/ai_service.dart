import 'package:flutter/foundation.dart';
import '../core/config/env.dart';

abstract class AiService {
  Future<String> generateText(String prompt);
  Future<List<String>> generateTaskBreakdown(String projectBrief);
  Future<String> converse(List<Map<String, String>> history, String message);
}

// 1. Mock Implementation (Bypasses errors when API keys are missing)
class MockAiServiceImpl implements AiService {
  @override
  Future<String> generateText(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));
    return 'Mock AI Response: Structured details for prompt "$prompt"';
  }

  @override
  Future<List<String>> generateTaskBreakdown(String projectBrief) async {
    await Future.delayed(const Duration(seconds: 1));
    return [
      'Task 1: Design database schema mapping matching "$projectBrief"',
      'Task 2: Implement remote Dio network controllers',
      'Task 3: Build responsive Material 3 UI pages',
      'Task 4: Write unit test verifications',
    ];
  }

  @override
  Future<String> converse(List<Map<String, String>> history, String message) async {
    await Future.delayed(const Duration(seconds: 1));
    final msgLower = message.toLowerCase();

    if (msgLower.contains('leave')) {
      return 'According to our company policy, you have 15 Casual Leaves and 8 Sick Leaves allocated annually. You have currently used 3 Casual Leaves. Would you like me to draft a leave request for you?';
    }
    if (msgLower.contains('payslip') || msgLower.contains('salary')) {
      return 'Your payslips are processed on the 28th of each month. You can download your June 2026 payslip directly in the Payroll panel under settings.';
    }
    if (msgLower.contains('hello') || msgLower.contains('hi')) {
      return 'Hello! I am your AI HR Assistant. You can ask me questions about company policies, leave allocations, task deadlines, or download forms.';
    }
    return 'I processed your query: "$message". Let me know if you need specific details about attendance logs, payroll calculations, or holidays.';
  }
}

// 2. Gemini implementation placeholder
class GeminiAiServiceImpl implements AiService {
  final String _apiKey;

  GeminiAiServiceImpl(this._apiKey);

  @override
  Future<String> generateText(String prompt) async {
    // Under real usage: Integrate google_generative_ai
    // final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    // final response = await model.generateContent([Content.text(prompt)]);
    // return response.text ?? '';
    return 'Gemini AI Response placeholder for: $prompt';
  }

  @override
  Future<List<String>> generateTaskBreakdown(String projectBrief) async {
    return [
      'Gemini Task 1: Setup project models',
      'Gemini Task 2: Build UI widgets',
    ];
  }

  @override
  Future<String> converse(List<Map<String, String>> history, String message) async {
    return 'Gemini conversational chat response.';
  }
}
