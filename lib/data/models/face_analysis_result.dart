import 'package:flutter/material.dart';

class FaceAnalysisResult {
  final String mood;
  final String analysisText;
  final double smileProb;
  final double stressLevel;
  final IconData icon;
  final Color color;

  FaceAnalysisResult({
    required this.mood,
    required this.analysisText,
    required this.smileProb,
    required this.stressLevel,
    required this.icon,
    required this.color,
  });
}
