import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chatbot_controller.dart';
import '../../../../core/themes/app_colors.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});

  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  final List<String> _promptSuggestions = [
    'Check my leave balance',
    'When is my next payslip?',
    'What is the standard clock-in policy?',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? text]) {
    final messageText = text ?? _textController.text;
    if (messageText.trim().isEmpty) return;

    ref.read(chatbotControllerProvider.notifier).sendMessage(messageText);
    
    if (text == null) {
      _textController.clear();
    }
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatbotControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Scroll to bottom whenever messages are updated
    ref.listen(chatbotControllerProvider, (previous, current) {
      _scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.indigoAccent),
            SizedBox(width: 8),
            Text('HR AI Copilot'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message History Container
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return _buildChatBubble(context, msg, isDark);
              },
            ),
          ),

          // Loading state indicator
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 16,
                width: 16,
                child: CircularProgressIndicator(strokeWidth: 2.0),
              ),
            ),

          // Suggestion Chips (Prompt triggers)
          if (state.messages.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _promptSuggestions.map((prompt) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ActionChip(
                        label: Text(
                          prompt,
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: isDark ? AppColors.obsidianSurface : Colors.grey[200],
                        side: BorderSide(color: Theme.of(context).dividerColor),
                        onPressed: () => _handleSend(prompt),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          // Chat Input controls bar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: isDark ? AppColors.obsidianSurface : Colors.white,
              border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (_) => _handleSend(),
                    decoration: InputDecoration(
                      hintText: 'Ask AI HR assistant anything...',
                      hintStyle: const TextStyle(fontSize: 14),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: isDark ? AppColors.obsidianBackground : Colors.grey[100],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                FloatingActionButton.small(
                  onPressed: () => _handleSend(),
                  elevation: 0,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  child: const Icon(Icons.send, size: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: msg.isUser
              ? Theme.of(context).colorScheme.primary
              : (isDark ? AppColors.obsidianBackground : Colors.grey[200]),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: msg.isUser ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: msg.isUser ? const Radius.circular(0) : const Radius.circular(12),
          ),
          border: !msg.isUser
              ? Border.all(color: Theme.of(context).dividerColor)
              : null,
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser
                ? Colors.white
                : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}
