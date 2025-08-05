import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mindcare/presentation/pages/tips/data/stress_tip.dart';

enum TipsLanguage { english, sinhala, tamil }

class ShortTipsData {
  static final String _geminiApiKey = dotenv.env['GEMINAI_API_KEY']!;
  static Map<String, List<StressTip>> _cachedTips = {};
  static GenerativeModel? _model;

  static GenerativeModel get _geminiModel {
    _model ??= GenerativeModel(
      model: 'gemini-1.5-flash', // Using more stable model
      apiKey: _geminiApiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7,
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 1000,
        stopSequences: [],
      ),
    );
    return _model!;
  }

  static Future<List<StressTip>> getShortStressTips({
    TipsLanguage language = TipsLanguage.english,
    String category = 'general',
    int count = 5,
    bool forceRefresh = false,
  }) async {
    final cacheKey = '${language.name}_${category}_short';
    
    if (_cachedTips[cacheKey] != null && !forceRefresh) {
      return _shuffleTips(_cachedTips[cacheKey]!).take(count).toList();
    }

    try {
      final aiTips = await _generateShortTips(
        language: language,
        category: category,
        count: count,
      );

      if (aiTips.isNotEmpty) {
        _cachedTips[cacheKey] = aiTips;
        return aiTips;
      } else {
        print('AI returned empty tips, using fallback');
        return _getShortFallbackTips(language, category, count);
      }
    } catch (e) {
      print('AI generation failed: $e');
      return _getShortFallbackTips(language, category, count);
    }
  }

  static Future<List<StressTip>> _generateShortTips({
    required TipsLanguage language,
    required String category,
    int count = 5,
  }) async {
    if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
      throw Exception('Please set your Gemini API key in the .env file');
    }

    final prompt = _buildShortTipsPrompt(language, category, count);
    
    try {
      final response = await _geminiModel.generateContent([
        Content.text(prompt)
      ]);
      
      if (response.text != null && response.text!.isNotEmpty) {
        return _parseShortTipsResponse(response.text!);
      } else {
        throw Exception('Empty response from Gemini AI');
      }
    } on GenerativeAIException catch (e) {
      // Handle specific Gemini API errors
      if (e.message.contains('503') || e.message.contains('overloaded')) {
        throw Exception('AI service temporarily unavailable');
      } else if (e.message.contains('quota') || e.message.contains('limit')) {
        throw Exception('API quota exceeded');
      } else if (e.message.contains('400') || e.message.contains('invalid')) {
        throw Exception('Invalid request format');
      } else {
        throw Exception('AI service error: ${e.message}');
      }
    } catch (e) {
      if (e.toString().contains('role: model')) {
        // SDK format issue - try alternative approach
        throw Exception('SDK format error - please update google_generative_ai package');
      }
      throw Exception('Network error: $e');
    }
  }

  static String _buildShortTipsPrompt(TipsLanguage language, String category, int count) {
    final languageName = _getLanguageName(language);
    final categoryDesc = _getCategoryDescription(category);

    return '''
Generate $count SHORT stress management tips in $languageName for $categoryDesc.

Requirements:
- Each tip should be 1-2 sentences maximum
- Focus on quick, actionable advice
- Make them practical and easy to remember
- Duration should be 1-5 minutes max

${_getLanguageInstructions(language)}

FORMAT AS JSON:
{
  "tips": [
    {
      "title": "Short title (3-5 words)",
      "description": "Brief 1-2 sentence description",
      "category": "$category",
      "difficulty": "easy",
      "duration": "2 minutes",
      "steps": ["Quick step 1", "Quick step 2"]
    }
  ]
}
''';
  }

  static String _getLanguageInstructions(TipsLanguage language) {
    switch (language) {
      case TipsLanguage.sinhala:
        return 'Write in Sinhala (සිංහල) - keep it simple and culturally relevant.';
      case TipsLanguage.tamil:
        return 'Write in Tamil (தமிழ்) - keep it simple and culturally relevant.';
      case TipsLanguage.english:
      default:
        return 'Write in simple, clear English.';
    }
  }

  static String _getCategoryDescription(String category) {
    switch (category) {
      case 'workplace': return 'work stress relief';
      case 'relationships': return 'social stress management';
      case 'physical': return 'physical stress relief';
      case 'mental': return 'mental clarity';
      case 'sleep': return 'better sleep';
      case 'breathing': return 'breathing techniques';
      case 'mindfulness': return 'mindfulness practices';
      default: return 'general stress relief';
    }
  }

  static String _getLanguageName(TipsLanguage language) {
    switch (language) {
      case TipsLanguage.sinhala: return 'Sinhala';
      case TipsLanguage.tamil: return 'Tamil';
      case TipsLanguage.english: default: return 'English';
    }
  }

  static List<StressTip> _parseShortTipsResponse(String response) {
    try {
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
      final tipsData = data['tips'] as List;
      
      return tipsData.map((tipData) {
        final stepsData = tipData['steps'] as List? ?? [];
        final steps = stepsData.map((step) => step.toString()).toList();
        
        return StressTip(
          title: tipData['title'].toString(),
          description: tipData['description'].toString(),
          category: tipData['category'].toString(),
          difficulty: tipData['difficulty']?.toString() ?? 'easy',
          duration: tipData['duration']?.toString() ?? '2 minutes',
          steps: steps,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse response: $e');
    }
  }

  static List<StressTip> _getShortFallbackTips(TipsLanguage language, String category, int count) {
    List<StressTip> tips;
    
    switch (language) {
      case TipsLanguage.sinhala:
        tips = _getSinhalaShortTips(category);
        break;
      case TipsLanguage.tamil:
        tips = _getTamilShortTips(category);
        break;
      case TipsLanguage.english:
      default:
        tips = _getEnglishShortTips(category);
        break;
    }

    return _shuffleTips(tips).take(count).toList();
  }

  static List<StressTip> _getEnglishShortTips(String category) {
    return [
      StressTip(
        title: "Take 5 Deep Breaths",
        description: "Breathe slowly and deeply to calm your mind instantly.",
        category: category,
        difficulty: "easy",
        duration: "1 minute",
        steps: ["Inhale for 4 counts", "Exhale for 6 counts"],
      ),
      StressTip(
        title: "Stretch Your Arms",
        description: "Release tension with simple arm stretches.",
        category: category,
        difficulty: "easy",
        duration: "2 minutes",
        steps: ["Raise arms overhead", "Hold for 10 seconds"],
      ),
      StressTip(
        title: "List 3 Good Things",
        description: "Focus on positive moments from today.",
        category: category,
        difficulty: "easy",
        duration: "2 minutes",
        steps: ["Think of 3 positives", "Feel grateful for each"],
      ),
      StressTip(
        title: "Drink Cold Water",
        description: "Hydrate and refresh to reset your energy.",
        category: category,
        difficulty: "easy",
        duration: "1 minute",
        steps: ["Get a glass of water", "Drink slowly and mindfully"],
      ),
      StressTip(
        title: "Step Outside",
        description: "Fresh air and natural light boost mood quickly.",
        category: category,
        difficulty: "easy",
        duration: "3 minutes",
        steps: ["Go outside", "Take a few deep breaths"],
      ),
    ];
  }

  static List<StressTip> _getSinhalaShortTips(String category) {
    return [
      StressTip(
        title: "ගැඹුරු හුස්ම 5ක්",
        description: "මනස 즉시 සන්සුන් කරන්න සඳහා සෙමින් ගැඹුරින් හුස්ම ගන්න.",
        category: category,
        difficulty: "පහසු",
        duration: "මිනිත්තු 1",
        steps: ["ගණන් 4ක් සඳහා හුස්ම ගන්න", "ගණන් 6ක් සඳහා පිට හරින්න"],
      ),
      StressTip(
        title: "අත් දිගු කරන්න",
        description: "සරල අත් දිගු කිරීම් සමඟ ආතතිය මුදා හරින්න.",
        category: category,
        difficulty: "පහසු",
        duration: "මිනිත්තු 2",
        steps: ["අත් ඉහළට එසවන්න", "තත්පර 10ක් රඳවන්න"],
      ),
      StressTip(
        title: "හොඳ දේවල් 3ක්",
        description: "අද දිනයේ ධනාත්මක මොහොතවල් කෙරෙහි අවධානය යොමු කරන්න.",
        category: category,
        difficulty: "පහසු",
        duration: "මිනිත්තු 2",
        steps: ["ධනාත්මක දේවල් 3ක් සිතන්න", "ඒ සෑම එකක් සඳහාම කෘතજ්ඤතාව දැනෙන්න"],
      ),
    ];
  }

  static List<StressTip> _getTamilShortTips(String category) {
    return [
      StressTip(
        title: "5 ஆழ்ந்த சுவாசங்கள்",
        description: "மனதை உடனடியாக அமைதிப்படுத்த மெதுவாக ஆழமாக சுவாசிக்கவும்.",
        category: category,
        difficulty: "எளிது",
        duration: "1 நிமிடம்",
        steps: ["4 எண்ணிக்கைக்கு சுவாசிக்கவும்", "6 எண்ணிக்கைக்கு வெளியேற்றவும்"],
      ),
      StressTip(
        title: "கைகளை நீட்டவும்",
        description: "எளிய கை நீட்டல்களுடன் பதற்றத்தை விடுவிக்கவும்.",
        category: category,
        difficulty: "எளிது",
        duration: "2 நிமிடங்கள்",
        steps: ["கைகளை மேலே உயர்த்தவும்", "10 வினாடிகள் பிடித்து வைக்கவும்"],
      ),
      StressTip(
        title: "3 நல்ல விஷயங்கள்",
        description: "இன்றைய நேர்மறையான தருணங்களில் கவனம் செலுத்துங்கள்.",
        category: category,
        difficulty: "எளிது",
        duration: "2 நிமிடங்கள்",
        steps: ["3 நேர்மறையானவற்றை நினைக்கவும்", "ஒவ்வொன்றுக்கும் நன்றியுணர்வு கொள்ளுங்கள்"],
      ),
    ];
  }

  static List<StressTip> _shuffleTips(List<StressTip> tips) {
    final shuffled = List<StressTip>.from(tips);
    shuffled.shuffle(Random());
    return shuffled;
  }

  // Quick utility methods
  static Future<List<StressTip>> getInstantTips({
    TipsLanguage language = TipsLanguage.english,
  }) async {
    return await getShortStressTips(
      language: language,
      category: 'general',
      count: 3,
    );
  }

  static Future<List<StressTip>> getWorkStressTips({
    TipsLanguage language = TipsLanguage.english,
  }) async {
    return await getShortStressTips(
      language: language,
      category: 'workplace',
      count: 4,
    );
  }

  static Future<List<StressTip>> getBreathingTips({
    TipsLanguage language = TipsLanguage.english,
  }) async {
    return await getShortStressTips(
      language: language,
      category: 'breathing',
      count: 3,
    );
  }

  static Future<void> clearCache() async {
    _cachedTips.clear();
  }

  // Test API connection and compatibility
  static Future<bool> testApiConnection() async {
    try {
      if (_geminiApiKey == 'YOUR_GEMINI_API_KEY_HERE' || _geminiApiKey.isEmpty) {
        print('API key not configured');
        return false;
      }
      
      final response = await _geminiModel.generateContent([
        Content.text('Respond with just "OK" if you can read this.')
      ]);
      
      final responseText = response.text?.trim() ?? '';
      print('API test response: $responseText');
      return responseText.isNotEmpty;
    } catch (e) {
      print('API test failed: $e');
      return false;
    }
  }

  static List<String> get shortCategories => [
    'general',
    'workplace',
    'breathing',
    'physical',
    'mindfulness'
  ];
}