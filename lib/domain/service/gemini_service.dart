import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/models/message.dart';

class GeminiService {
  final GenerativeModel _model;
  
  late final Map<String, String> _prompts;
  late final Map<String, String> _errorMessages;
  late final Map<String, String> _errorWithDetailsMessages;

  static final String _apiKey = dotenv.env['GEMINAI_API_KEY'] ?? '';

  GeminiService() : _model = GenerativeModel(
          model: 'gemini-2.0-flash',
          apiKey: _apiKey,
        ) {
    _initializePrompts();
    _initializeErrorMessages();
  }

  void _initializePrompts() {
    _prompts = {
      'english': dotenv.env['DEFAULT_PROMPT_ENGLISH']!,
      'sinhala': dotenv.env['DEFAULT_PROMPT_SINHALA']!,
      'tamil': dotenv.env['DEFAULT_PROMPT_TAMIL']!,
    };
  }

  void _initializeErrorMessages() {
    _errorMessages = {
      'english': dotenv.env['ERROR_MESSAGE_ENGLISH']!,
      'sinhala': dotenv.env['ERROR_MESSAGE_SINHALA']!,
      'tamil': dotenv.env['ERROR_MESSAGE_TAMIL']!,
    };

    _errorWithDetailsMessages = {
      'english': dotenv.env['ERROR_WITH_DETAILS_ENGLISH']!,
      'sinhala': dotenv.env['ERROR_WITH_DETAILS_SINHALA']!,
      'tamil': dotenv.env['ERROR_WITH_DETAILS_TAMIL']!,
    };
  }

  String _detectLanguage(String text) {
    if (text.contains(RegExp(r'[\u0D80-\u0DFF]'))) {
      return 'sinhala';
    } else if (text.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
      return 'tamil';
    } else {
      return 'english';
    }
  }

  void updatePrompt(String language, String newPrompt) {
    if (_prompts.containsKey(language)) {
      _prompts[language] = newPrompt;
    }
  }

  String getPrompt(String language) {
    return _prompts[language]!;
  }

  Future<String> generateResponse(List<Message> chatHistory, {String? language}) async {
    try {
      if (_apiKey.isEmpty) {
        throw Exception('Gemini API key not found in environment variables');
      }

      final userMessage = chatHistory.last.text;      
      final detectedLanguage = language ?? _detectLanguage(userMessage);      
      final systemPrompt = _prompts[detectedLanguage]!;
      final combinedPrompt = "$systemPrompt\n\nUser: $userMessage";
      final response = await _model.generateContent([Content.text(combinedPrompt)]);

      return response.text ?? _getErrorMessage(detectedLanguage);
    } catch (e) {
      final detectedLanguage = language ?? _detectLanguage(chatHistory.last.text);
      return _getErrorMessage(detectedLanguage, e.toString());
    }
  }

  String _getErrorMessage(String language, [String? error]) {
    if (error != null) {
      final template = _errorWithDetailsMessages[language]!;
      return template.replaceAll('{error}', error);
    } else {
      return _errorMessages[language]!;
    }
  }

  bool validateConfiguration() {
    return _apiKey.isNotEmpty && 
           _prompts.isNotEmpty && 
           _errorMessages.isNotEmpty;
  }

  Map<String, dynamic> getConfigurationStatus() {
    return {
      'hasApiKey': _apiKey.isNotEmpty,
      'availableLanguages': _prompts.keys.toList(),
      'promptsLoaded': _prompts.length,
      'errorMessagesLoaded': _errorMessages.length,
    };
  }
}