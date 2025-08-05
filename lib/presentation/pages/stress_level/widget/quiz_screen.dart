import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';

class QuizScreen extends StatelessWidget {
  final int currentQuestionIndex;
  final List<QuizQuestion> questions;
  final List<int> answers;
  final Function(int) onAnswerSelected;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  const QuizScreen({
    Key? key,
    required this.currentQuestionIndex,
    required this.questions,
    required this.answers,
    required this.onAnswerSelected,
    required this.onNext,
    required this.onPrevious,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasAnswer = answers.length > currentQuestionIndex;
    QuizQuestion currentQuestion = questions[currentQuestionIndex];
    
    return Column(
      children: [
        // Progress indicator
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          child: Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (currentQuestionIndex + 1) / questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${currentQuestionIndex + 1}/${questions.length}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),

        // Quiz header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            'QUESTION ${currentQuestionIndex + 1}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 30),

        // Question
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            currentQuestion.question,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),

        const SizedBox(height: 20),

        // Answer options
        Expanded(
          child: ListView.builder(
            itemCount: currentQuestion.options.length,
            itemBuilder: (context, index) {
              final option = currentQuestion.options[index];
              bool isSelected = hasAnswer && answers[currentQuestionIndex] == option.value;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () => onAnswerSelected(option.value),
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? Colors.blue : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Radio<int>(
                          value: option.value,
                          groupValue: hasAnswer ? answers[currentQuestionIndex] : null,
                          onChanged: (value) => onAnswerSelected(value!),
                          activeColor: Colors.blue,
                        ),
                        Expanded(
                          child: Text(
                            option.text,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.blue : Colors.black87,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Navigation buttons
        Row(
          children: [
            if (currentQuestionIndex > 0)
              Expanded(
                child: ElevatedButton(
                  onPressed: onPrevious,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            
            if (currentQuestionIndex > 0) const SizedBox(width: 10),
            
            Expanded(
              child: ElevatedButton(
                onPressed: hasAnswer ? onNext : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: hasAnswer ? Colors.blue : Colors.grey[300],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: Text(
                  currentQuestionIndex == questions.length - 1 ? 'Finish' : 'Next',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}