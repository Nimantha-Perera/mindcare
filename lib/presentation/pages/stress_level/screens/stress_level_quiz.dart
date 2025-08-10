import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';
import 'package:mindcare/presentation/pages/stress_level/util/stress_calculater.dart';
import 'package:mindcare/presentation/pages/stress_level/widget/quiz_screen.dart';
import 'package:mindcare/presentation/pages/stress_level/widget/result_screen.dart';
import '../data/quiz_data.dart';

enum Language { english, sinhala, tamil }

class StressLevelQuiz extends StatefulWidget {
  const StressLevelQuiz({Key? key}) : super(key: key);

  @override
  _StressLevelQuizState createState() => _StressLevelQuizState();
}

class _StressLevelQuizState extends State<StressLevelQuiz> {
  int currentQuestionIndex = 0;
  List<int> answers = [];
  bool showResults = false;
  List<QuizQuestion>? questions;
  bool isLoading = false;
  bool isGeneratingQuestions = false;
  String loadingMessage = '';
  Language selectedLanguage = Language.english;
  bool showLanguageSelection = true;

  @override
  void initState() {
    super.initState();
    // Don't load questions immediately, wait for language selection
  }

  // Load questions based on selected language
  Future<void> _loadQuestions() async {
    setState(() {
      isLoading = true;
      isGeneratingQuestions = true;
      loadingMessage = _getLoadingMessage();
    });

    try {
      List<QuizQuestion> loadedQuestions;

      // Add a small delay to show the loading message
      await Future.delayed(const Duration(milliseconds: 500));

      switch (selectedLanguage) {
        case Language.english:
          setState(() {
            loadingMessage = 'Generating English questions...';
          });
          loadedQuestions = await QuizData.getQuestions();
          break;
        case Language.sinhala:
          setState(() {
            loadingMessage = 'සිංහල ප්‍රශ්න සකස් කරමින්...';
          });
          loadedQuestions = await QuizData.getSinhalaQuestions();
          break;
        case Language.tamil:
          setState(() {
            loadingMessage = 'தமிழ் கேள்விகளை உருவாக்குகிறது...';
          });
          loadedQuestions = await QuizData.getTamilQuestions();
          break;
      }

      if (mounted) {
        setState(() {
          questions = loadedQuestions;
          isLoading = false;
          isGeneratingQuestions = false;
          showLanguageSelection = false;
          loadingMessage = '';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          isGeneratingQuestions = false;
          loadingMessage = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load questions: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _getLoadingMessage() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'ප්‍රශ්න සකස් කරමින්...';
      case Language.tamil:
        return 'கேள்விகளை தயாரிக்கிறது...';
      default:
        return 'Generating questions...';
    }
  }

  void selectLanguage(Language language) {
    setState(() {
      selectedLanguage = language;
    });
    _loadQuestions();
  }

  void selectAnswer(int value) {
    setState(() {
      if (answers.length > currentQuestionIndex) {
        answers[currentQuestionIndex] = value;
      } else {
        answers.add(value);
      }
    });
  }

  void nextQuestion() {
    if (questions != null && currentQuestionIndex < questions!.length - 1) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      setState(() {
        showResults = true;
      });
    }
  }

  void previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
      });
    }
  }

  void resetQuiz() {
    setState(() {
      currentQuestionIndex = 0;
      answers.clear();
      showResults = false;
      showLanguageSelection = true;
      questions = null;
      isLoading = false;
      isGeneratingQuestions = false;
      loadingMessage = '';
    });
  }

  void changeLanguage() {
    setState(() {
      showLanguageSelection = true;
      showResults = false;
      currentQuestionIndex = 0;
      answers.clear();
      questions = null;
      isLoading = false;
      isGeneratingQuestions = false;
      loadingMessage = '';
    });
  }

  Widget _buildLanguageSelection() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Language / භාෂාව තෝරන්න / மொழியைத் தேர்ந்தெடுக்கவும்',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // English Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isGeneratingQuestions
                  ? null
                  : () => selectLanguage(Language.english),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'English',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Sinhala Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isGeneratingQuestions
                  ? null
                  : () => selectLanguage(Language.sinhala),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'සිංහල',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tamil Button
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: isGeneratingQuestions
                  ? null
                  : () => selectLanguage(Language.tamil),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
              child: const Text(
                'தமிழ்',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated loading indicator
          SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getLoadingColor(),
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Loading message
          Text(
            loadingMessage,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15),

          // Sub message
          Text(
            _getSubLoadingMessage(),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Progress dots animation
          _buildProgressDots(),
        ],
      ),
    );
  }

  Widget _buildProgressDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 600 + (index * 200)),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: _getLoadingColor().withOpacity(0.7),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  Color _getLoadingColor() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return Colors.green[600]!;
      case Language.tamil:
        return Colors.orange[600]!;
      default:
        return Colors.blue[600]!;
    }
  }

  String _getSubLoadingMessage() {
    switch (selectedLanguage) {
      case Language.sinhala:
        return 'කරුණාකර රැඳී සිටින්න...';
      case Language.tamil:
        return 'தயவுசெய்து காத்திருக்கவும்...';
      default:
        return 'Please wait...';
    }
  }

  String _getAppBarTitle() {
    if (isGeneratingQuestions) {
      switch (selectedLanguage) {
        case Language.sinhala:
          return 'ප්‍රශ්න සකස් කරමින්';
        case Language.tamil:
          return 'கேள்விகள் தயாரிப்பு';
        default:
          return 'Generating Questions';
      }
    }

    switch (selectedLanguage) {
      case Language.sinhala:
        return 'ආතතිය මට්ටම් ප්‍රශ්නාවලිය';
      case Language.tamil:
        return 'மன அழுத்த நிலை வினாடி வினா';
      default:
        return 'Stress Level Quiz';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
        actions: [
          if (!showLanguageSelection && !isLoading && !isGeneratingQuestions)
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: changeLanguage,
              tooltip: 'Change Language',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: showLanguageSelection
            ? _buildLanguageSelection()
            : isLoading || isGeneratingQuestions
                ? _buildLoadingScreen()
                : questions == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: Colors.red[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Failed to load questions. Please try again.',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: changeLanguage,
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      )
                    : showResults
                        ? ResultsScreen(
                            stressResult: StressCalculator.getStressLevel(
                                answers, questions!.length),
                            onRestart: resetQuiz,
                          )
                        : QuizScreen(
                            currentQuestionIndex: currentQuestionIndex,
                            questions: questions!,
                            answers: answers,
                            onAnswerSelected: selectAnswer,
                            onNext: nextQuestion,
                            onPrevious: previousQuestion,
                          ),
      ),
    );
  }
}
