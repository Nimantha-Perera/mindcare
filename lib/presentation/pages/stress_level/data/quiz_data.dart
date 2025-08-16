import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';

enum QuizLanguage { english, sinhala, tamil }

class QuizData {
  static final String _geminiApiKey = dotenv.env['GEMINAI_API_KEY']!;
  

  static Map<QuizLanguage, List<QuizQuestion>> _cachedQuestions = {};
  static GenerativeModel? _model;
  
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


  static Future<List<QuizQuestion>> getQuestions({bool forceRefresh = false}) async {
    return getQuestionsInLanguage(QuizLanguage.english, forceRefresh: forceRefresh);
  }


  static Future<List<QuizQuestion>> getSinhalaQuestions({bool forceRefresh = false}) async {
    return getQuestionsInLanguage(QuizLanguage.sinhala, forceRefresh: forceRefresh);
  }

  static Future<List<QuizQuestion>> getTamilQuestions({bool forceRefresh = false}) async {
    return getQuestionsInLanguage(QuizLanguage.tamil, forceRefresh: forceRefresh);
  }

  
  static Future<List<QuizQuestion>> getQuestionsInLanguage(
    QuizLanguage language, {
    bool forceRefresh = false
  }) async {

    if (_cachedQuestions[language] != null && !forceRefresh) {
      return _shuffleQuestions(_cachedQuestions[language]!);
    }

  
    final aiQuestions = await _generateQuestionsWithAI(language: language);
    if (aiQuestions.isNotEmpty) {
      _cachedQuestions[language] = aiQuestions;
      return _shuffleQuestions(aiQuestions);
    } else {
      throw Exception('Failed to generate ${_getLanguageName(language)} questions from Gemini AI');
    }
  }

  static Future<List<QuizQuestion>> _generateQuestionsWithAI({
    QuizLanguage language = QuizLanguage.english
  }) async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key in the .env file');
    }

    final systemPrompt = _buildSystemPrompt(language);
    
    final content = [Content.text(systemPrompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null && response.text!.isNotEmpty) {
      return _parseAIResponse(response.text!);
    } else {
      throw Exception('Empty response from Gemini AI');
    }
  }


  static Future<List<QuizQuestion>> generateQuestionsWithConfig(
    QuizConfig config, {
    QuizLanguage language = QuizLanguage.english
  }) async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key in the .env file');
    }

    final customPrompt = _buildCustomPrompt(config, language);
    
    final content = [Content.text(customPrompt)];
    final response = await _geminiModel.generateContent(content);

    if (response.text != null && response.text!.isNotEmpty) {
      final questions = _parseAIResponse(response.text!);
      return questions.take(config.questionCount).toList();
    } else {
      throw Exception('Empty response from Gemini AI');
    }
  }

 
  static String _buildSystemPrompt(QuizLanguage language) {
    final languageInstructions = _getLanguageInstructions(language);
    final sampleQuestion = _getSampleQuestion(language);
    
    return '''
You are a mental health professional creating a stress assessment quiz in ${_getLanguageName(language)}. Generate 10 diverse, clinically-informed questions to evaluate stress levels.

$languageInstructions

REQUIREMENTS:
1. Each question must have exactly 5 answer options
2. Options should be scored 0-4 (0 = no stress, 4 = high stress)
3. Cover different stress domains: physical, emotional, cognitive, behavioral, social
4. Use clear, non-judgmental language appropriate for ${_getLanguageName(language)} speakers
5. Avoid clinical jargon
6. Make questions relatable to general population
7. Ensure cultural sensitivity and appropriateness

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

$sampleQuestion

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


  static String _buildCustomPrompt(QuizConfig config, QuizLanguage language) {
    final languageInstructions = _getLanguageInstructions(language);
    final domainText = config.preferredDomains.isNotEmpty 
        ? 'Focus primarily on these domains: ${config.preferredDomains.join(', ')}'
        : 'Cover all stress domains equally';

    final difficultyText = config.difficultyLevel < 0.3 
        ? 'Use simple, basic questions suitable for general screening'
        : config.difficultyLevel > 0.7 
            ? 'Include complex, detailed questions for comprehensive assessment'
            : 'Use moderately detailed questions for balanced assessment';

    return '''
You are a mental health professional creating a customized stress assessment quiz in ${_getLanguageName(language)}. Generate ${config.questionCount} diverse, clinically-informed questions.

$languageInstructions

CUSTOMIZATION REQUIREMENTS:
- $domainText
- $difficultyText
- ${config.includePhysicalSymptoms ? 'Include' : 'Minimize'} physical symptom questions
- ${config.includeEmotionalWellbeing ? 'Include' : 'Minimize'} emotional wellbeing questions  
- ${config.includeCognitiveFunction ? 'Include' : 'Minimize'} cognitive function questions

STANDARD REQUIREMENTS:
1. Each question must have exactly 5 answer options
2. Options should be scored 0-4 (0 = no stress, 4 = high stress)
3. Use clear, non-judgmental language appropriate for ${_getLanguageName(language)} speakers
4. Make questions relatable to general population
5. Ensure cultural sensitivity and appropriateness

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

 
  static String _getLanguageInstructions(QuizLanguage language) {
    switch (language) {
      case QuizLanguage.sinhala:
        return '''
SINHALA LANGUAGE REQUIREMENTS:
- Write all questions and answers in proper Sinhala script (සිංහල)
- Use formal but accessible Sinhala language
- Ensure proper grammar and sentence structure
- Use culturally appropriate terms and concepts
- Avoid direct translations - adapt concepts to Sinhala cultural context
- Use respectful and non-stigmatizing language about mental health
''';
      case QuizLanguage.tamil:
        return '''
TAMIL LANGUAGE REQUIREMENTS:
- Write all questions and answers in proper Tamil script (தமிழ்)
- Use formal but accessible Tamil language
- Ensure proper grammar and sentence structure
- Use culturally appropriate terms and concepts
- Avoid direct translations - adapt concepts to Tamil cultural context
- Use respectful and non-stigmatizing language about mental health
''';
      case QuizLanguage.english:
      default:
        return '''
ENGLISH LANGUAGE REQUIREMENTS:
- Use clear, simple English suitable for diverse English speakers
- Avoid complex medical terminology
- Use inclusive and culturally sensitive language
- Ensure accessibility for non-native English speakers
''';
    }
  }


  static String _getSampleQuestion(QuizLanguage language) {
    switch (language) {
      case QuizLanguage.sinhala:
        return '''
SAMPLE QUESTION FORMAT:
{
  "question": "පසුගිය සතියේ ඔබට කෙතරම් නිතර නින්දට යාමට අපහසු වී තිබේද?",
  "options": [
    {"text": "කිසිදා නැත", "value": 0},
    {"text": "කලාතුරකින්", "value": 1},
    {"text": "සමහර විට", "value": 2},
    {"text": "බොහෝ විට", "value": 3},
    {"text": "සෑම දිනකම", "value": 4}
  ]
}
''';
      case QuizLanguage.tamil:
        return '''
SAMPLE QUESTION FORMAT:
{
  "question": "கடந்த வாரத்தில் நீங்கள் எவ்வளவு அடிக்கடி தூங்குவதில் சிரமம் அனுபவித்தீர்கள்?",
  "options": [
    {"text": "ஒருபோதும் இல்லை", "value": 0},
    {"text": "அரிதாக", "value": 1},
    {"text": "சில நேரங்களில்", "value": 2},
    {"text": "அடிக்கடி", "value": 3},
    {"text": "தினமும்", "value": 4}
  ]
}
''';
      case QuizLanguage.english:
      default:
        return '''
SAMPLE QUESTION FORMAT:
{
  "question": "How often have you had trouble falling asleep in the past week?",
  "options": [
    {"text": "Never", "value": 0},
    {"text": "Rarely", "value": 1},
    {"text": "Sometimes", "value": 2},
    {"text": "Often", "value": 3},
    {"text": "Every day", "value": 4}
  ]
}
''';
    }
  }


  static String _getLanguageName(QuizLanguage language) {
    switch (language) {
      case QuizLanguage.sinhala:
        return 'Sinhala';
      case QuizLanguage.tamil:
        return 'Tamil';
      case QuizLanguage.english:
      default:
        return 'English';
    }
  }

 
  static List<QuizQuestion> _parseAIResponse(String response) {
  
    String cleanResponse = response.trim();
    

    if (cleanResponse.startsWith('```json')) {
      cleanResponse = cleanResponse.substring(7);
    }
    if (cleanResponse.endsWith('```')) {
      cleanResponse = cleanResponse.substring(0, cleanResponse.length - 3);
    }
    

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


  static List<QuizQuestion> _shuffleQuestions(List<QuizQuestion> questions) {
    final shuffled = List<QuizQuestion>.from(questions);
    shuffled.shuffle(Random());
    return shuffled;
  }


  static Future<List<QuizQuestion>> getQuestionSubset(int count, {QuizLanguage language = QuizLanguage.english}) async {
    final allQuestions = await getQuestionsInLanguage(language);
    if (allQuestions.length <= count) {
      return allQuestions;
    }
    
    final shuffled = List<QuizQuestion>.from(allQuestions);
    shuffled.shuffle(Random());
    return shuffled.take(count).toList();
  }

  static Future<void> refreshQuestions({QuizLanguage? language}) async {
  if (language != null) {

    _cachedQuestions.remove(language);
    await getQuestionsInLanguage(language, forceRefresh: true);
  } else {

    _cachedQuestions.clear();
    await getQuestions(forceRefresh: true);
  }
}

  static Future<List<QuizQuestion>> getQuestionsByDomains(
    List<String> domains, {
    QuizLanguage language = QuizLanguage.english
  }) async {
    final config = QuizConfig(
      preferredDomains: domains,
      questionCount: 8,
    );
    return await generateQuestionsWithConfig(config, language: language);
  }


  static Future<List<QuizQuestion>> getQuestionsForLevel(
    String level, {
    QuizLanguage language = QuizLanguage.english
  }) async {
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
    
    return await generateQuestionsWithConfig(config, language: language);
  }


  static bool get isApiKeyConfigured => 
      _geminiApiKey != 'YOUR_GEMINI_API_KEY_HERE' && _geminiApiKey.isNotEmpty;


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

  /// Get available languages
  static List<QuizLanguage> get availableLanguages => QuizLanguage.values;

  /// Get language display name
  static String getLanguageDisplayName(QuizLanguage language) {
    switch (language) {
      case QuizLanguage.english:
        return 'English';
      case QuizLanguage.sinhala:
        return 'සිංහල';
      case QuizLanguage.tamil:
        return 'தமிழ்';
    }
  }

  /// Get language code
  static String getLanguageCode(QuizLanguage language) {
    switch (language) {
      case QuizLanguage.english:
        return 'en';
      case QuizLanguage.sinhala:
        return 'si';
      case QuizLanguage.tamil:
        return 'ta';
    }
  }

  /// Convert language enum from string
  static QuizLanguage? getLanguageFromString(String languageString) {
    switch (languageString.toLowerCase()) {
      case 'english':
      case 'en':
        return QuizLanguage.english;
      case 'sinhala':
      case 'si':
        return QuizLanguage.sinhala;
      case 'tamil':
      case 'ta':
        return QuizLanguage.tamil;
      default:
        return null;
    }
  }

  /// Clear cache for specific language
  static void clearLanguageCache(QuizLanguage language) {
    _cachedQuestions.remove(language);
  }

  /// Clear all caches
  static void clearAllCaches() {
    _cachedQuestions.clear();
  }

  /// Check if questions are cached for a language
  static bool isLanguageCached(QuizLanguage language) {
    return _cachedQuestions[language] != null && _cachedQuestions[language]!.isNotEmpty;
  }

  /// Get cached question count for a language
  static int getCachedQuestionCount(QuizLanguage language) {
    return _cachedQuestions[language]?.length ?? 0;
  }

  static Future<void> preloadAllLanguages() async {
    final futures = QuizLanguage.values.map((language) => 
        getQuestionsInLanguage(language, forceRefresh: false));
    await Future.wait(futures);
  }

 
  static Future<List<QuizQuestion>> getMixedLanguageQuestions({
    required Map<QuizLanguage, int> languageDistribution,
  }) async {
    final allQuestions = <QuizQuestion>[];
    
    for (final entry in languageDistribution.entries) {
      final language = entry.key;
      final count = entry.value;
      
      if (count > 0) {
        final questions = await getQuestionSubset(count, language: language);
        allQuestions.addAll(questions);
      }
    }
    
    return _shuffleQuestions(allQuestions);
  }
}

extension QuizQuestionExtension on QuizQuestion {
  
  double get difficulty {
    final values = options.map((o) => o.value).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    return (maxValue - minValue) / 4.0;
  }

 
  String get domain {
    final questionLower = question.toLowerCase();
    
    // English keywords
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
    
    // Sinhala keywords
    else if (questionLower.contains('නින්ද') || questionLower.contains('විශ්‍රාම')) {
      return 'sleep';
    } else if (questionLower.contains('හිසරදය') || 
               questionLower.contains('ආතතිය') || 
               questionLower.contains('ශාරීරික')) {
      return 'physical';
    } else if (questionLower.contains('කනස්සල්ල') || 
               questionLower.contains('මනෝභාවය')) {
      return 'emotional';
    } else if (questionLower.contains('අවධානය') || 
               questionLower.contains('මතකය')) {
      return 'cognitive';
    } else if (questionLower.contains('වැඩ') || 
               questionLower.contains('වගකීම්')) {
      return 'work-life';
    }
    
    // Tamil keywords
    else if (questionLower.contains('தூக்கம்') || questionLower.contains('ஓய்வு')) {
      return 'sleep';
    } else if (questionLower.contains('தலைவலி') || 
               questionLower.contains('பதற்றம்') || 
               questionLower.contains('உடல்')) {
      return 'physical';
    } else if (questionLower.contains('கவலை') || 
               questionLower.contains('மனநிலை')) {
      return 'emotional';
    } else if (questionLower.contains('கவனம்') || 
               questionLower.contains('நினைவு')) {
      return 'cognitive';
    } else if (questionLower.contains('வேலை') || 
               questionLower.contains('பொறுப்பு')) {
      return 'work-life';
    }
    
    return 'general';
  }


  QuizLanguage get detectedLanguage {
    final questionText = question;
    
    // Check for Sinhala script
    if (RegExp(r'[\u0D80-\u0DFF]').hasMatch(questionText)) {
      return QuizLanguage.sinhala;
    }
    
    // Check for Tamil script
    if (RegExp(r'[\u0B80-\u0BFF]').hasMatch(questionText)) {
      return QuizLanguage.tamil;
    }
    
    // Default to English
    return QuizLanguage.english;
  }


  bool get isCulturallyAppropriate {
    final lang = detectedLanguage;
    final questionLower = question.toLowerCase();
    
  
    switch (lang) {
      case QuizLanguage.sinhala:
  
        return !questionLower.contains('පිස්සු') && 
               !questionLower.contains('අපරාධ'); 
      case QuizLanguage.tamil:
   
        return !questionLower.contains('பைத்தியம்') && 
               !questionLower.contains('குற்றம்');
      case QuizLanguage.english:
      default:

        return !questionLower.contains('crazy') &&
               !questionLower.contains('insane') &&
               !questionLower.contains('mental');
    }
  }
}


class QuizConfig {
  final int questionCount;
  final List<String> preferredDomains;
  final double difficultyLevel;
  final bool includePhysicalSymptoms;
  final bool includeEmotionalWellbeing;
  final bool includeCognitiveFunction;
  final QuizLanguage language;
  final bool culturallyAdapted;
  
  const QuizConfig({
    this.questionCount = 8,
    this.preferredDomains = const [],
    this.difficultyLevel = 0.5,
    this.includePhysicalSymptoms = true,
    this.includeEmotionalWellbeing = true,
    this.includeCognitiveFunction = true,
    this.language = QuizLanguage.english,
    this.culturallyAdapted = true,
  });


  QuizConfig copyWithLanguage(QuizLanguage newLanguage) {
    return QuizConfig(
      questionCount: questionCount,
      preferredDomains: preferredDomains,
      difficultyLevel: difficultyLevel,
      includePhysicalSymptoms: includePhysicalSymptoms,
      includeEmotionalWellbeing: includeEmotionalWellbeing,
      includeCognitiveFunction: includeCognitiveFunction,
      language: newLanguage,
      culturallyAdapted: culturallyAdapted,
    );
  }
}


class QuizAnalytics {

  static Map<String, int> analyzeDomainDistribution(List<QuizQuestion> questions) {
    final distribution = <String, int>{};
    
    for (final question in questions) {
      final domain = question.domain;
      distribution[domain] = (distribution[domain] ?? 0) + 1;
    }
    
    return distribution;
  }


  static double getAverageDifficulty(List<QuizQuestion> questions) {
    if (questions.isEmpty) return 0.0;
    
    final totalDifficulty = questions
        .map((q) => q.difficulty)
        .reduce((a, b) => a + b);
    
    return totalDifficulty / questions.length;
  }


  static Map<QuizLanguage, int> analyzeLanguageDistribution(List<QuizQuestion> questions) {
    final distribution = <QuizLanguage, int>{};
    
    for (final question in questions) {
      final language = question.detectedLanguage;
      distribution[language] = (distribution[language] ?? 0) + 1;
    }
    
    return distribution;
  }


  static double getCulturalAppropriatenessScore(List<QuizQuestion> questions) {
    if (questions.isEmpty) return 0.0;
    
    final appropriateCount = questions
        .where((q) => q.isCulturallyAppropriate)
        .length;
    
    return appropriateCount / questions.length;
  }

  /// Get comprehensive analytics report
  static Map<String, dynamic> getComprehensiveAnalytics(List<QuizQuestion> questions) {
    return {
      'totalQuestions': questions.length,
      'domainDistribution': analyzeDomainDistribution(questions),
      'languageDistribution': analyzeLanguageDistribution(questions),
      'averageDifficulty': getAverageDifficulty(questions),
      'culturalAppropriatenessScore': getCulturalAppropriatenessScore(questions),
      'questionsPerLanguage': {
        for (final lang in QuizLanguage.values)
          QuizData.getLanguageDisplayName(lang): questions
              .where((q) => q.detectedLanguage == lang)
              .length
      },
    };
  }
}