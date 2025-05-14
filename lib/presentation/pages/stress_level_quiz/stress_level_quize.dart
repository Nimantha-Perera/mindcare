import 'package:flutter/material.dart';

class StressLevelQuiz extends StatefulWidget {
  final Function(int) onComplete;

  const StressLevelQuiz({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<StressLevelQuiz> createState() => _StressLevelQuizState();
}

class _StressLevelQuizState extends State<StressLevelQuiz> {
  int _currentQuestionIndex = 0;
  List<int> _answers = [0, 0, 0, 0, 0];
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'How often do you feel overwhelmed by your responsibilities?',
      'options': [
        '(1) Rarely – I manage tasks with ease',
        '(2) Occasionally – I feel pressure but can handle it',
        '(3) Frequently – I struggle to keep up',
        '(4) Almost always – I feel completely overwhelmed',
      ]
    },
    {
      'question': 'How well do you sleep at night?',
      'options': [
        '(1) Very well – I rarely have trouble sleeping',
        '(2) Adequately – I sometimes have difficulty',
        '(3) Poorly – I often struggle to fall or stay asleep',
        '(4) Very poorly – Sleep issues affect me almost daily',
      ]
    },
    {
      'question': 'How often do you experience physical symptoms of stress (headaches, tension, etc.)?',
      'options': [
        '(1) Rarely or never',
        '(2) Occasionally – A few times a month',
        '(3) Regularly – Several times a week',
        '(4) Daily – These symptoms are constant',
      ]
    },
    {
      'question': 'How would you rate your ability to relax and unwind?',
      'options': [
        '(1) Excellent – I can easily relax when needed',
        '(2) Good – I usually find ways to relax',
        '(3) Fair – I often struggle to truly relax',
        '(4) Poor – I rarely feel relaxed',
      ]
    },
    {
      'question': 'How often do you feel irritable or quick to anger?',
      'options': [
        '(1) Rarely – I maintain my composure easily',
        '(2) Sometimes – Occasional irritability',
        '(3) Often – I get irritated several times a week',
        '(4) Very often – I feel on edge most days',
      ]
    },
  ];

  void _selectAnswer(int answerIndex) {
    setState(() {
      _answers[_currentQuestionIndex] = answerIndex + 1;
      
      if (_currentQuestionIndex < _questions.length - 1) {
        _currentQuestionIndex++;
      } else {
        _calculateStressLevel();
      }
    });
  }

  void _calculateStressLevel() {
    int totalScore = _answers.reduce((sum, score) => sum + score);
    
    // Score ranges: 5-8: Low, 9-13: Moderate, 14-17: High, 18-20: Severe
    int stressLevel = 1; // Low
    
    if (totalScore >= 9 && totalScore <= 13) {
      stressLevel = 2; // Moderate
    } else if (totalScore >= 14 && totalScore <= 17) {
      stressLevel = 3; // High
    } else if (totalScore >= 18) {
      stressLevel = 4; // Severe
    }
    
    widget.onComplete(stressLevel);
  }
  
  void _goBack() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildProgressIndicator(),
              const SizedBox(height: 24),
              _buildQuizHeader(),
              const SizedBox(height: 40),
              _buildQuestion(),
              const SizedBox(height: 40),
              ..._buildAnswerOptions(),
              const Spacer(),
              _buildNavigation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Flexible(
            flex: (_currentQuestionIndex + 1),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Flexible(
            flex: _questions.length - (_currentQuestionIndex + 1),
            child: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
        color: Colors.white,
      ),
      child: const Text(
        'QUIZ 1',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildQuestion() {
    return Text(
      _questions[_currentQuestionIndex]['question'],
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildAnswerOptions() {
    List<Widget> options = [];
    List<String> questionOptions = _questions[_currentQuestionIndex]['options'];
    
    for (int i = 0; i < questionOptions.length; i++) {
      final bool isSelected = _answers[_currentQuestionIndex] == i + 1;
      
      options.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Material(
            borderRadius: BorderRadius.circular(100),
            color: isSelected ? const Color(0xFF00796B) : Colors.white,
            child: InkWell(
              borderRadius: BorderRadius.circular(100),
              onTap: () => _selectAnswer(i),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  questionOptions[i],
                  style: TextStyle(
                    fontSize: 16,
                    color: isSelected ? Colors.white : Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return options;
  }

  Widget _buildNavigation() {
    return Row(
      children: [
        if (_currentQuestionIndex > 0)
          Expanded(
            child: TextButton(
              onPressed: _goBack,
              child: const Text('Back'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        if (_currentQuestionIndex > 0)
          const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _answers[_currentQuestionIndex] != 0
                ? () => _currentQuestionIndex == _questions.length - 1
                    ? _calculateStressLevel()
                    : _selectAnswer(_answers[_currentQuestionIndex] - 1)
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              elevation: 2,
            ),
            child: Text(
              _currentQuestionIndex == _questions.length - 1 ? 'Submit' : 'Next',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Example usage:
class StressQuizScreen extends StatelessWidget {
  const StressQuizScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StressLevelQuiz(
      onComplete: (stressLevel) {
        // Handle the stress level result
        String result = 'Low';
        if (stressLevel == 2) result = 'Moderate';
        if (stressLevel == 3) result = 'High';
        if (stressLevel == 4) result = 'Severe';
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Stress Assessment Result'),
            content: Text('Your stress level: $result'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }
}