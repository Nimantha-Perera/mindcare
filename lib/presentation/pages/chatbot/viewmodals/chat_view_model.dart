import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/message.dart';
import 'package:mindcare/domain/service/gemini_service.dart';

class ChatViewModel extends ChangeNotifier {
  List<Message> _messages = [];
  bool _isLoading = false;
  final String _botName = "Happy Bot";
  final GeminiService _geminiService = GeminiService();
  final User? user = FirebaseAuth.instance.currentUser;
  String _selectedLanguage = 'auto'; // auto, english, sinhala, tamil

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String get botName => _botName;
  String get selectedLanguage => _selectedLanguage;

  ChatViewModel() {
    // Initialize with sample messages
    _messages = [
      Message(text: "Hi I need help", isFromUser: true),
      Message(
        text: "Hello ${user?.displayName ?? 'User'},\nhow can i help you today", 
        isFromUser: false, 
        senderName: "Bot"
      ),
    ];
  }

  // Set language preference
  void setLanguage(String language) {
    _selectedLanguage = language;
    notifyListeners();
    
    // Update welcome message based on language
    _updateWelcomeMessage();
  }

  void _updateWelcomeMessage() {
    final welcomeMessages = {
      'english': "Hello ${user?.displayName ?? 'User'},\nhow can I help you today?",
      'sinhala': "ආයුබෝවන් ${user?.displayName ?? 'පරිශීලක'},\nකොහොමද ඔයාගෙ අද දවස?",
      'tamil': "வணக்கம் ${user?.displayName ?? 'பயனர்'},\nஇன்று நான் உங்களுக்கு எவ்வாறு உதவ முடியும்?",
    };

    if (_messages.length > 1) {
      final language = _selectedLanguage == 'auto' ? 'english' : _selectedLanguage;
      _messages[1] = Message(
        text: welcomeMessages[language] ?? welcomeMessages['english']!,
        isFromUser: false,
        senderName: "Bot"
      );
      notifyListeners();
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(Message(text: text, isFromUser: true));
    notifyListeners();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Get response from Gemini API with language preference
      final language = _selectedLanguage == 'auto' ? null : _selectedLanguage;
      final response = await _geminiService.generateResponse(_messages, language: language);
      
      // Add bot response
      _messages.add(Message(
        text: response,
        isFromUser: false,
        senderName: "Bot",
      ));
    } catch (e) {
      // Add error message if API call fails
      final errorMessages = {
        'english': "Sorry, I couldn't process your request at the moment.",
        'sinhala': "සමාවන්න, මට දැන් ඔබේ ඉල්ලීම සැකසීමට නොහැකි විය.",
        'tamil': "மன்னிக்கவும், இந்த நேரத்தில் உங்கள் கோரிக்கையை என்னால் செயல்படுத்த முடியவில்லை."
      };
      
      final language = _selectedLanguage == 'auto' ? 'english' : _selectedLanguage;
      _messages.add(Message(
        text: errorMessages[language] ?? errorMessages['english']!,
        isFromUser: false,
        senderName: "Bot",
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear chat history
  void clearChat() {
    _messages.clear();
    // Re-add welcome message
    _messages.add(Message(text: "Hi I need help", isFromUser: true));
    _updateWelcomeMessage();
    notifyListeners();
  }

  get isTyping => null;
}