import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';
import 'package:mindcare/presentation/pages/stress_level/util/stress_calculater.dart';
import 'package:mindcare/presentation/pages/stress_level/widget/quiz_screen.dart';
import 'package:mindcare/presentation/pages/stress_level/widget/result_screen.dart';
import '../data/quiz_data.dart';

class StressLevelQuiz extends StatefulWidget {
  const StressLevelQuiz({Key? key}) : super(key: key);

  @override
  _StressLevelQuizState createState() => _StressLevelQuizState();
}

class _StressLevelQuizState extends State<StressLevelQuiz> {
  int currentQuestionIndex = 0;
  List<int> answers = [];
  bool showResults = false;
  List<QuizQuestion>? questions; // Make this nullable
  bool isLoading = true; // Add loading state
  
  @override
  void initState() {
    super.initState();
    _loadQuestions(); // Call async method without awaiting
  }

  // Separate async method to load questions
  Future<void> _loadQuestions() async {
    try {
      final loadedQuestions = await QuizData.getQuestions();
      if (mounted) { // Check if widget is still mounted
        setState(() {
          questions = loadedQuestions;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          // Handle error - you might want to show an error message
        });
        // Optionally show error dialog or snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load questions: $e')),
        );
      }
    }
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Stress Level Quiz'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
          ? const Center(
              child: CircularProgressIndicator(), // Show loading indicator
            )
          : questions == null
              ? const Center(
                  child: Text('Failed to load questions. Please try again.'),
                )
              : showResults 
                  ? ResultsScreen(
                      stressResult: StressCalculator.getStressLevel(answers, questions!.length),
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