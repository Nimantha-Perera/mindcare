class QuizQuestion {
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.question,
    required this.options,
  });
}

class QuizOption {
  final String text;
  final int value;

  QuizOption({
    required this.text,
    required this.value,
  });
}

class StressResult {
  final String level;
  final String description;
  final double percentage;
  final int score;
  final int maxScore;

  StressResult({
    required this.level,
    required this.description,
    required this.percentage,
    required this.score,
    required this.maxScore,
  });
}