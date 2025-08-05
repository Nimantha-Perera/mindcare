import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';


class StressCalculator {
  static int calculateScore(List<int> answers) {
    return answers.fold(0, (sum, answer) => sum + answer);
  }

  static StressResult getStressLevel(List<int> answers, int totalQuestions) {
    int score = calculateScore(answers);
    int maxScore = totalQuestions * 4;
    double percentage = (score / maxScore) * 100;

    String level;
    String description;

    if (percentage <= 20) {
      level = 'Low Stress';
      description = 'You\'re managing stress well. Keep up the good work! Your current stress levels are healthy and manageable.';
    } else if (percentage <= 40) {
      level = 'Mild Stress';
      description = 'You have some stress, but it\'s manageable with good habits. Consider incorporating relaxation techniques into your routine.';
    } else if (percentage <= 60) {
      level = 'Moderate Stress';
      description = 'Your stress levels are concerning. Consider stress management techniques like exercise, meditation, or talking to someone you trust.';
    } else if (percentage <= 80) {
      level = 'High Stress';
      description = 'You\'re experiencing significant stress. It would be beneficial to seek professional help or counseling to develop coping strategies.';
    } else {
      level = 'Very High Stress';
      description = 'Your stress levels are very concerning. Please consider seeking professional support immediately. You don\'t have to handle this alone.';
    }

    return StressResult(
      level: level,
      description: description,
      percentage: percentage,
      score: score,
      maxScore: maxScore,
    );
  }

  static Color getStressColor(double percentage) {
    if (percentage <= 20) {
      return Colors.green;
    } else if (percentage <= 40) {
      return Colors.lightGreen;
    } else if (percentage <= 60) {
      return Colors.orange;
    } else if (percentage <= 80) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}