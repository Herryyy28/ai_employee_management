import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/ai_service.dart';
import '../../../../core/config/service_locator.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ChatbotState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatbotState({
    this.messages = const [],
    this.isLoading = false,
  });

  ChatbotState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
  }) {
    return ChatbotState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatbotController extends StateNotifier<ChatbotState> {
  final AiService _aiService;

  ChatbotController(this._aiService)
      : super(
          ChatbotState(
            messages: [
              ChatMessage(
                text: 'Hello! I am your AI HR Assistant. You can ask me about leaves, payslips, policies or workspace routines.',
                isUser: false,
              ),
            ],
          ),
        );

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(text: text, isUser: true);
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isLoading: true,
    );

    try {
      // Build conversation history format for AI service consumption
      final history = state.messages.map((m) {
        return {
          'role': m.isUser ? 'user' : 'model',
          'parts': m.text,
        };
      }).toList();

      final aiResponse = await _aiService.converse(history, text);
      final botMessage = ChatMessage(text: aiResponse, isUser: false);
      
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isLoading: false,
      );
    } catch (e) {
      final errorMessage = ChatMessage(
        text: 'Sorry, I encountered an issue. Please try again.',
        isUser: false,
      );
      state = state.copyWith(
        messages: [...state.messages, errorMessage],
        isLoading: false,
      );
    }
  }
}

final chatbotControllerProvider = StateNotifierProvider<ChatbotController, ChatbotState>((ref) {
  return ChatbotController(sl<AiService>());
});
