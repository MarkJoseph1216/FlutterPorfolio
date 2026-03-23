import 'package:flutter/material.dart';
import 'chatbot_widget.dart'; // adjust path if needed

/// A zero-config entry point that wires up [ChatbotWidget] with your
/// Gemini API key.  Drop `const ChatBubble()` anywhere in a [Stack] and
/// it will render the floating bubble + slide-up panel.
///
/// Keep your key in a separate secrets file (e.g. lib/core/constants/api_keys.dart)
/// and never commit it to version control.
class ChatBubble extends StatelessWidget {
  const ChatBubble({super.key});

  static const String _geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');

  @override
  Widget build(BuildContext context) {
    return ChatbotWidget(apiKey: _geminiApiKey);
  }
}