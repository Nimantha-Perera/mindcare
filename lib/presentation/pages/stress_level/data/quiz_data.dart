import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';

class QuizData {
  static final String _geminiApiKey = dotenv.env['GEMINAI_API_KEY']!;
  
  // Cache for generated questions to avoid repeated API calls
  static List<QuizQuestion>? _cachedQuestions;
  static GenerativeModel? _model;
  
  // Initialize the Gemini model
  static GenerativeModel get _geminiModel {
    _model ??= GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
    );
    return _model!;
  }

  /// Get questions - either from cache or AI generation
  static Future<List<QuizQuestion>> getQuestions({bool forceRefresh = false}) async {
    // Return cached questions if available and not forcing refresh
    if (_cachedQuestions != null && !forceRefresh) {
      return _shuffleQuestions(_cachedQuestions!);
    }

    // Generate new questions using AI
    final aiQuestions = await _generateQuestionsWithAI();
    if (aiQuestions.isNotEmpty) {
      _cachedQuestions = aiQuestions;
      return _shuffleQuestions(aiQuestions);
    } else {
      throw Exception('Failed to generate questions from Gemini AI');
    }
  }

  /// Generate questions using Gemini AI
  static Future<List<QuizQuestion>> _generateQuestionsWithAI() async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key in the .env file');
    }

    final systemPrompt = _buildSystemPrompt();
    
    final content = [Content.text(systemPrompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null && response.text!.isNotEmpty) {
      return _parseAIResponse(response.text!);
    } else {
      throw Exception('Empty response from Gemini AI');
    }
  }

  /// Generate questions with specific configuration
  static Future<List<QuizQuestion>> generateQuestionsWithConfig(QuizConfig config) async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key in the .env file');
    }

    final customPrompt = _buildCustomPrompt(config);
    
    final content = [Content.text(customPrompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null && response.text!.isNotEmpty) {
      final questions = _parseAIResponse(response.text!);
      return questions.take(config.questionCount).toList();
    } else {
      throw Exception('Empty response from Gemini AI');
    }
  }

  /// Build the system prompt for AI question generation
  static String _buildSystemPrompt() {
    return '''
You are a mental health professional creating a stress assessment quiz. Generate 10 diverse, clinically-informed questions to evaluate stress levels.

REQUIREMENTS:
1. Each question must have exactly 5 answer options
2. Options should be scored 0-4 (0 = no stress, 4 = high stress)
3. Cover different stress domains: physical, emotional, cognitive, behavioral, social
4. Use clear, non-judgmental language
5. Avoid clinical jargon
6. Make questions relatable to general population

DOMAINS TO COVER:
- Sleep quality and patterns
- Physical symptoms (headaches, tension, fatigue)  
- Emotional regulation and mood
- Cognitive functioning (concentration, memory)
- Work/life balance and responsibilities
- Social relationships and support
- Coping mechanisms and resilience
- Life satisfaction and control
- Energy levels and motivation
- Appetite and eating patterns

FORMAT YOUR RESPONSE AS VALID JSON ONLY:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": [
        {"text": "Option 1", "value": 0},
        {"text": "Option 2", "value": 1},
        {"text": "Option 3", "value": 2},
        {"text": "Option 4", "value": 3},
        {"text": "Option 5", "value": 4}
      ]
    }
  ]
}

Generate varied, evidence-based questions that provide accurate stress assessment. Ensure progressive severity in answer options from minimal to significant stress indicators.
''';
  }

  /// Build custom prompt based on configuration
  static String _buildCustomPrompt(QuizConfig config) {
    final domainText = config.preferredDomains.isNotEmpty 
        ? 'Focus primarily on these domains: ${config.preferredDomains.join(', ')}'
        : 'Cover all stress domains equally';

    final difficultyText = config.difficultyLevel < 0.3 
        ? 'Use simple, basic questions suitable for general screening'
        : config.difficultyLevel > 0.7 
            ? 'Include complex, detailed questions for comprehensive assessment'
            : 'Use moderately detailed questions for balanced assessment';

    return '''
You are a mental health professional creating a customized stress assessment quiz. Generate ${config.questionCount} diverse, clinically-informed questions.

CUSTOMIZATION REQUIREMENTS:
- $domainText
- $difficultyText
- ${config.includePhysicalSymptoms ? 'Include' : 'Minimize'} physical symptom questions
- ${config.includeEmotionalWellbeing ? 'Include' : 'Minimize'} emotional wellbeing questions  
- ${config.includeCognitiveFunction ? 'Include' : 'Minimize'} cognitive function questions

STANDARD REQUIREMENTS:
1. Each question must have exactly 5 answer options
2. Options should be scored 0-4 (0 = no stress, 4 = high stress)
3. Use clear, non-judgmental language
4. Make questions relatable to general population

FORMAT YOUR RESPONSE AS VALID JSON ONLY:
{
  "questions": [
    {
      "question": "Question text here?",
      "options": [
        {"text": "Option 1", "value": 0},
        {"text": "Option 2", "value": 1},
        {"text": "Option 3", "value": 2},
        {"text": "Option 4", "value": 3},
        {"text": "Option 5", "value": 4}
      ]
    }
  ]
}

Generate evidence-based questions with progressive severity in options.
''';
  }

  /// Parse AI response and convert to QuizQuestion objects
  static List<QuizQuestion> _parseAIResponse(String response) {
    // Clean the response to extract JSON
    String cleanResponse = response.trim();
    
    // Remove markdown code blocks if present
    if (cleanResponse.startsWith('```json')) {
      cleanResponse = cleanResponse.substring(7);
    }
    if (cleanResponse.endsWith('```')) {
      cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
    }
    
    // Find JSON start and end
    final jsonStart = cleanResponse.indexOf('{');
    final jsonEnd = cleanResponse.lastIndexOf('}') + 1;
    
    if (jsonStart != -1 && jsonEnd > jsonStart) {
      cleanResponse = cleanResponse.substring(jsonStart, jsonEnd);
    }
    
    final data = jsonDecode(cleanResponse);
    final questionsData = data['questions'] as List;
    
    return questionsData.map((questionData) {
      final optionsData = questionData['options'] as List;
      final options = optionsData.map((optionData) {
        return QuizOption(
          text: optionData['text'].toString(),
          value: optionData['value'] is int 
              ? optionData['value'] 
              : int.parse(optionData['value'].toString()),
        );
      }).toList();
      
      return QuizQuestion(
        question: questionData['question'].toString(),
        options: options,
      );
    }).toList();
  }

  /// Shuffle questions for variety
  static List<QuizQuestion> _shuffleQuestions(List<QuizQuestion> questions) {
    final shuffled = List<QuizQuestion>.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }

  /// Get a subset of questions (useful for shorter quizzes)
  static Future<List<QuizQuestion>> getQuestionSubset(int count) async {
    final allQuestions = await getQuestions();
    if (allQuestions.length <= count) {
      return allQuestions;
    }
    
    final shuffled = List<QuizQuestion>.from(allQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(count).toList();
  }

  /// Refresh questions cache
  static Future<void> refreshQuestions() async {
    _cachedQuestions = null;
    await getQuestions(forceRefresh: true);
  }

  /// Get questions by specific domains
  static Future<List<QuizQuestion>> getQuestionsByDomains(List<String> domains) async {
    final config = QuizConfig(
      preferredDomains: domains,
      questionCount: 8,
    );
    return await generateQuestionsWithConfig(config);
  }

  /// Generate questions for specific stress levels
  static Future<List<QuizQuestion>> getQuestionsForLevel(String level) async {
    QuizConfig config;
    
    switch (level.toLowerCase()) {
      case 'basic':
        config = const QuizConfig(
          questionCount: 5,
          difficultyLevel: 0.2,
          preferredDomains: ['sleep', 'mood', 'energy'],
        );
        break;
      case 'comprehensive':
        config = const QuizConfig(
          questionCount: 15,
          difficultyLevel: 0.8,
          includePhysicalSymptoms: true,
          includeEmotionalWellbeing: true,
          includeCognitiveFunction: true,
        );
        break;
      default:
        config = const QuizConfig(questionCount: 8);
    }
    
    return await generateQuestionsWithConfig(config);
  }

  /// Check if API key is configured
  static bool get isApiKeyConfigured => 
      _geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && _geminiApiKey.isNotEmpty;

  /// Test API connection
  static Future<bool> testApiConnection() async {
    try {
      if (!isApiKeyConfigured) return false;
      
      final testContent = [Content.text('Respond with just "OK" if you can read this.')];
      final response = await _geminiModel.generateContent(testContent);
      
      return response.text != null && response.text!.trim().isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

/// Extension to add question difficulty levels
extension QuizQuestionExtension on QuizQuestion {
  /// Calculate question difficulty based on option distribution
  double get difficulty {
    final values = options.map((o) => o.value).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return (maxValue - minValue) / 4.0;
  }

  /// Get the stress domain this question likely covers
  String get domain {
    final questionLower = question.toLowerCase();
    
    if (questionLower.contains('sleep') || questionLower.contains('rest')) {
      return 'sleep';
    } else if (questionLower.contains('headache') || 
               questionLower.contains('tension') || 
               questionLower.contains('physical')) {
      return 'physical';
    } else if (questionLower.contains('anxious') || 
               questionLower.contains('worry') || 
               questionLower.contains('mood')) {
      return 'emotional';
    } else if (questionLower.contains('concentrate') || 
               questionLower.contains('memory') || 
               questionLower.contains('focus')) {
      return 'cognitive';
    } else if (questionLower.contains('work') || 
               questionLower.contains('responsibility')) {
      return 'work-life';
    } else if (questionLower.contains('control') || 
               questionLower.contains('manage')) {
      return 'control';
    }
    
    return 'general';
  }
}

/// Configuration class for quiz generation
class QuizConfig {
  final int questionCount;
  final List<String> preferredDomains;
  final double difficultyLevel; // 0.0 to 1.0
  final bool includePhysicalSymptoms;
  final bool includeEmotionalWellbeing;
  final bool includeCognitiveFunction;
  
  const QuizConfig({
    this.questionCount = 8,
    this.preferredDomains = const [],
    this.difficultyLevel = 0.5,
    this.includePhysicalSymptoms = true,
    this.includeEmotionalWellbeing = true,
    this.includeCognitiveFunction = true,
  });
}

/// Helper class for quiz analytics
class QuizAnalytics {
  /// Analyze question distribution by domain
  static Map<String, int> analyzeDomainDistribution(List<QuizQuestion> questions) {
    final distribution = <String, int>{};
    
    for (final question in questions) {
      final domain = question.domain;
      distribution[domain] = (distribution[domain] ?? 0) + 1;
    }
    
    return distribution;
  }

  /// Get average difficulty of questions
  static double getAverageDifficulty(List<QuizQuestion> questions) {
    if (questions.isEmpty) return 0.0;
    
    final totalDifficulty = questions
        .map((q) => q.difficulty)
        .reduce((a, b) => a + b);
    
    return totalDifficulty / questions.length;
  }
}