import 'package:flutter/material.dart';

/// Utility class for mood-related operations.
class MoodUtils {
  /// Returns a color based on the mood.
  static Color getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
        return Colors.green.shade700;
      case 'happy':
        return Colors.green;
      case 'neutral':
        return Colors.amber;
      case 'a little sad':
        return Colors.blue;
      case 'sad':
        return Colors.blue.shade700;
      case 'eyes closed':
        return Colors.purple;
      case 'winking':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Returns an icon based on the mood.
  static IconData getMoodIcon(String mood) {
    switch (mood.toLowerCase()) {
      case 'very happy':
        return Icons.sentiment_very_satisfied;
      case 'happy':
        return Icons.sentiment_satisfied;
      case 'neutral':
        return Icons.sentiment_neutral;
      case 'a little sad':
        return Icons.sentiment_dissatisfied;
      case 'sad':
        return Icons.sentiment_very_dissatisfied;
      case 'eyes closed':
        return Icons.visibility_off;
      case 'winking':
        return Icons.face_retouching_natural;
      default:
        return Icons.face_outlined;
    }
  }

  /// Returns an analysis text based on mood and stress level.
  static String getAnalysisText(String mood, double stressLevel) {
    if (stressLevel > 0.7) {
      return "High stress detected. Try deep breathing.";
    } else if (stressLevel > 0.4) {
      return "Moderate stress. Consider relaxing.";
    }

    switch (mood.toLowerCase()) {
      case 'very happy':
        return "You're glowing with happiness!";
      case 'happy':
        return "You look cheerful!";
      case 'neutral':
        return "You seem balanced and calm.";
      case 'a little sad':
        return "Take a short walk or rest.";
      case 'sad':
        return "You seem down. Try relaxing or talking to someone.";
      case 'eyes closed':
        return "Eyes closed – maybe resting?";
      case 'winking':
        return "Winking detected!";
      default:
        return "Tap 'Analyze' to detect your mood.";
    }
  }
}
