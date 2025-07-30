import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/models/message.dart';

class GeminiService {
  final GenerativeModel _model;
  
  // Multi-language prompts loaded from .env
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

  // Initialize prompts from environment variables
  void _initializePrompts() {
    _prompts = {
      'english': dotenv.env['DEFAULT_PROMPT_ENGLISH']!,
      'sinhala': dotenv.env['DEFAULT_PROMPT_SINHALA']!,
      'tamil': dotenv.env['DEFAULT_PROMPT_TAMIL']!,
    };
  }

  // Initialize error messages from environment variables
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

  // Language detection based on text content
  String _detectLanguage(String text) {
    // Simple language detection logic
    if (text.contains(RegExp(r'[\u0D80-\u0DFF]'))) {
      return 'sinhala'; // Sinhala Unicode range
    } else if (text.contains(RegExp(r'[\u0B80-\u0BFF]'))) {
      return 'tamil'; // Tamil Unicode range
    } else {
      return 'english'; // Default to English
    }
  }

  // Method to update prompts at runtime (optional)
  void updatePrompt(String language, String newPrompt) {
    if (_prompts.containsKey(language)) {
      _prompts[language] = newPrompt;
    }
  }

  // Method to get current prompt for a language
  String getPrompt(String language) {
    return _prompts[language]!;
  }

  // Alternative method: Allow explicit language setting
  Future<String> generateResponse(List<Message> chatHistory, {String? language}) async {
    try {
      // Validate API key
      if (_apiKey.isEmpty) {
        throw Exception('Gemini API key not found in environment variables');
      }

      // Get the user's message
      final userMessage = chatHistory.last.text;
      
      // Detect language if not explicitly provided
      final detectedLanguage = language ?? _detectLanguage(userMessage);
      
      // Get the appropriate prompt
      final systemPrompt = _prompts[detectedLanguage]!;

      // Create a combined prompt with system instructions and user message
      final combinedPrompt = "$systemPrompt\n\nUser: $userMessage";

      // Generate content using the model
      final response = await _model.generateContent([Content.text(combinedPrompt)]);

      // Extract the text from the response
      return response.text ?? _getErrorMessage(detectedLanguage);
    } catch (e) {
      // Return error message in appropriate language
      final detectedLanguage = language ?? _detectLanguage(chatHistory.last.text);
      return _getErrorMessage(detectedLanguage, e.toString());
    }
  }

  // Get error messages in different languages
  String _getErrorMessage(String language, [String? error]) {
    if (error != null) {
      final template = _errorWithDetailsMessages[language]!;
      return template.replaceAll('{error}', error);
    } else {
      return _errorMessages[language]!;
    }
  }

  // Method to validate configuration
  bool validateConfiguration() {
    return _apiKey.isNotEmpty && 
           _prompts.isNotEmpty && 
           _errorMessages.isNotEmpty;
  }

  // Method to get configuration status
  Map<String, dynamic> getConfigurationStatus() {
    return {
      'hasApiKey': _apiKey.isNotEmpty,
      'availableLanguages': _prompts.keys.toList(),
      'promptsLoaded': _prompts.length,
      'errorMessagesLoaded': _errorMessages.length,
    };
  }
}