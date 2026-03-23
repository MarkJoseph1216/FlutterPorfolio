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

  static const String _geminiApiKey = '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';

  @override
  Widget build(BuildContext context) {
    return ChatbotWidget(apiKey: _geminiApiKey);
  }
}