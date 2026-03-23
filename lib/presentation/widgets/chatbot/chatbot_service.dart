// ignore: avoid_web_libraries_in_flutter
import 'dart:convert';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import '../../../data/repositories/portfolio_repository.dart';

/// Handles communication with OpenRouter API.
/// Free tier — no billing setup required.
/// Models: https://openrouter.ai/models?q=free
class ChatbotService {
  ChatbotService({required this.apiKey});

  final String apiKey;

  static const _endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  // Free model on OpenRouter — no credits needed
  static const _model = 'meta-llama/llama-3.2-3b-instruct:free';

  static String get _systemPrompt => '''
You are a friendly AI assistant on ${PortfolioRepository.name}'s portfolio website.
Your job is to answer questions visitors have about ${PortfolioRepository.name}.

Here is everything you know about them:

NAME: ${PortfolioRepository.name}
ROLE: ${PortfolioRepository.role}
LOCATION: ${PortfolioRepository.location}
EXPERIENCE: ${PortfolioRepository.experience}
EMAIL: ${PortfolioRepository.email}
GITHUB: ${PortfolioRepository.github}
LINKEDIN: ${PortfolioRepository.linkedin}

BIO:
${PortfolioRepository.bio1}
${PortfolioRepository.bio2}

PROJECTS:
${PortfolioRepository.projects.map((p) => '- ${p.title} (${p.year}): ${p.description} Stack: ${p.techStack.join(', ')}').join('\n')}

SKILLS:
${PortfolioRepository.skillGroups.map((g) => '${g.label}: ${g.skills.join(', ')}').join('\n')}

RULES:
- Keep answers short and friendly (2-3 sentences max)
- Only answer questions about ${PortfolioRepository.name} and their work
- If asked something unrelated, politely redirect to portfolio topics
- If asked for contact, share the email: ${PortfolioRepository.email}
- Never make up information not listed above
- Use a warm, professional tone
''';

  Future<String> send({
    required String userMessage,
    required List<ChatMessage> history,
  }) async {
    final messages = [
      {'role': 'system', 'content': _systemPrompt},
      ...history.map((m) => {
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.text,
          }),
      {'role': 'user', 'content': userMessage},
    ];

    final body = jsonEncode({
      'model': _model,
      'messages': messages,
      'max_tokens': 256,
      'temperature': 0.7,
    });

    final response = await html.HttpRequest.request(
      _endpoint,
      method: 'POST',
      requestHeaders: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://portfolio.app', // required by OpenRouter
        'X-Title': 'Portfolio Chatbot', // optional but recommended
      },
      sendData: body,
    );

    if (response.status != 200) {
      throw Exception(
        'OpenRouter error ${response.status}: ${response.responseText}',
      );
    }

    final data = jsonDecode(response.responseText!);
    final text = data['choices']?[0]?['message']?['content'];

    if (text == null || (text as String).isEmpty) {
      throw Exception('Empty response: ${response.responseText}');
    }

    return (text as String).trim();
  }
}

/// A single chat message.
class ChatMessage {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });

  final String text;
  final bool isUser;
  final DateTime timestamp;
}
