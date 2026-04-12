import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class EmailService {
  static const String _emailJsServiceId = 'service_ppt1du6';
  static const String _emailJsTemplateId = 'template_1jrsj2h';
  static const String _emailJsUserId = 'KGuijtZVoOFKrEJx5';

  static const String _smtpEndpoint = 'https://formspree.io/f/mojpggea';
  static const String _recipientEmail = 'imrkjoseph16@gmail.com';

  static Future<bool> _sendViaEmailJS({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.emailjs.com/api/v1.0/email/send'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _emailJsServiceId,
          'template_id': _emailJsTemplateId,
          'user_id': _emailJsUserId,
          'template_params': {
            'from_name': name,
            'from_email': email,
            'message': message,
            'subject': 'Portfolio Contact from $name',
            'to_email': _recipientEmail,
            'received_date': DateTime.now().toLocal().toString().split('.')[0],
          },
        }),
      );

      print('EmailJS Response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('EmailJS Error: $e');
      return false;
    }
  }

  static Future<bool> _sendViaSMTP({
    required String name,
    required String email,
    required String message,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_smtpEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'name': name,
          'email': email,
          'message': message,
          '_subject': 'Portfolio Contact from $name',
          '_replyto': email,
        }),
      );

      print('SMTP Response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('SMTP Error: $e');
      return false;
    }
  }

  static Future<bool> _sendViaEmailClient({
    required String name,
    required String email,
    required String message,
  }) async {
    final subject = 'Portfolio Contact: $name';
    final body = '''
      Name: $name
      Email: $email
      
      Message:
      $message
      ''';

    final emailUri = Uri(
      scheme: 'mailto',
      path: _recipientEmail,
      query:
          'subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
        return true;
      }
      return false;
    } catch (e) {
      print('Email client error: $e');
      return false;
    }
  }

  static Future<SendResult> sendEmailWithFallback({
    required String name,
    required String email,
    required String message,
    required Function(String status, String method) onStatus,
  }) async {
    onStatus('Sending via EmailJS...', 'EmailJS');
    final emailJsSuccess = await _sendViaEmailJS(
      name: name,
      email: email,
      message: message,
    );

    if (emailJsSuccess) {
      return SendResult(
        success: true,
        method: 'EmailJS',
        message: 'Message sent successfully',
      );
    }

    onStatus('EmailJS failed, trying SMTP...', 'SMTP');
    final smtpSuccess = await _sendViaSMTP(
      name: name,
      email: email,
      message: message,
    );

    if (smtpSuccess) {
      return SendResult(
        success: true,
        method: 'SMTP',
        message: 'Message sent successfully',
      );
    }

    onStatus('Opening your email app...', 'Email Client');
    final clientSuccess = await _sendViaEmailClient(
      name: name,
      email: email,
      message: message,
    );

    if (clientSuccess) {
      return SendResult(
        success: true,
        method: 'Email Client',
        message: 'Opening email app... Please send the message.',
      );
    }

    return SendResult(
      success: false,
      method: 'None',
      message: 'Unable to send message. Please email me directly at $_recipientEmail',
    );
  }
}

class SendResult {
  final bool success;
  final String method;
  final String message;

  SendResult({
    required this.success,
    required this.method,
    required this.message,
  });
}
