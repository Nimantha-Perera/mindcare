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

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String get botName => _botName;

  ChatViewModel() {
    // Initialize with sample messages from the image
    _messages = [
      Message(text: "Hi I need help", isFromUser: true),
      Message(text: "Hello ${user?.displayName ?? 'User'},\nhow can i help you today", isFromUser: false, senderName: "Bot"),
    ];
  }

  get isTyping => null;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    _messages.add(Message(text: text, isFromUser: true));
    notifyListeners();

    // Set loading state
    _isLoading = true;
    notifyListeners();

    try {
      // Get response from Gemini API
      final response = await _geminiService.generateResponse(_messages);
      
      // Add bot response
      _messages.add(Message(
        text: response,
        isFromUser: false,
        senderName: "Bot",
      ));
    } catch (e) {
      // Add error message if API call fails
      _messages.add(Message(
        text: "Sorry, I couldn't process your request at the moment.",
        isFromUser: false,
        senderName: "Bot",
      ));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}