import 'package:google_generative_ai/google_generative_ai.dart';
import '../../domain/models/message.dart';

class GeminiService {
  final GenerativeModel _model;
  final String _defaultPrompt = '''
You are a compassionate mental health professional named Happy Bot. 
Always respond with empathy, understanding, and professional expertise.
Keep responses concise and helpful.
If someone appears to be in crisis, gently suggest they seek immediate professional help.
Provide practical self-care tips and strategies when appropriate.
Maintain confidentiality and assure users their concerns are valid.
Do not diagnose but offer support and general information.
Use a warm, caring tone in all communications.
Format important advice or takeaways with markdown for clarity.
Respond in the same language the user writes in.
''';
  
  // Replace with your actual API key
  static const String _apiKey = 'AIzaSyDy8cctoZxEmnDhUpJ_-60I0HBT7RNRpdI';

  GeminiService() 
      : _model = GenerativeModel(
          model: 'gemini-1.5-pro',
          apiKey: _apiKey,
        );

  Future<String> generateResponse(List<Message> chatHistory) async {
    try {
      // Create content with the default prompt
      final systemContent = Content.text(_defaultPrompt);
      
      // Create content with the user's message
      final userMessage = chatHistory.last.text;
      final userContent = Content.text(userMessage);
      
      // Create a combined prompt with both system instructions and user message
      final combinedPrompt = "$_defaultPrompt\n\nUser: $userMessage";
      
      
      // Generate content using the model
      final response = await _model.generateContent(
        [Content.text(combinedPrompt)]
      );
      
      // Extract the text from the response
      return response.text ?? "I'm sorry, I couldn't generate a response.";
    } catch (e) {
      return "Sorry, I encountered an error: $e";
    }
  }
}