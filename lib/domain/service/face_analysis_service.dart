import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import '../../data/models/face_analysis_result.dart';

class FaceAnalysisService {
  static FaceAnalysisResult analyze(List<Face> faces) {
    if (faces.isEmpty) {
      return FaceAnalysisResult(
        mood: "No Face",
        analysisText: "No face detected. Try again.",
        smileProb: 0.0,
        stressLevel: 0.0,
        icon: Icons.face_outlined,
        color: Colors.grey,
      );
    }

    final face = faces.first;
    final smileProb = face.smilingProbability ?? 0.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final leftEye = face.leftEyeOpenProbability ?? 1.0;

    final sadness = 1.0 - smileProb;
    final eyeStress = ((rightEye + leftEye) / 2.0) * 0.5;
    final stress = (sadness * 0.7 + eyeStress * 0.3).clamp(0.0, 1.0);

    String mood = "Neutral";
    IconData icon = Icons.sentiment_neutral;
    Color color = Colors.amber;
    String analysis = "You seem balanced and calm.";

    if (smileProb > 0.6) {
      mood = "Very Happy";
      icon = Icons.sentiment_very_satisfied;
      color = Colors.green.shade700;
      analysis = "You're glowing with happiness!";
    } else if (smileProb > 0.3) {
      mood = "Happy";
      icon = Icons.sentiment_satisfied;
      color = Colors.green;
      analysis = "You look cheerful!";
    } else if (sadness > 0.7) {
      mood = "Sad";
      icon = Icons.sentiment_very_dissatisfied;
      color = Colors.blue.shade700;
      analysis = "You seem down. Try relaxing or talking to someone.";
    } else if (sadness > 0.5) {
      mood = "A Little Sad";
      icon = Icons.sentiment_dissatisfied;
      color = Colors.blue;
      analysis = "Take a short walk or rest.";
    }

    if (rightEye < 0.5 && leftEye < 0.5) {
      mood = "Eyes Closed";
      icon = Icons.visibility_off;
      color = Colors.purple;
      analysis = "Eyes closed – maybe resting?";
    } else if (rightEye < 0.5 || leftEye < 0.5) {
      mood = "Winking";
      icon = Icons.face_retouching_natural;
      color = Colors.orange;
      analysis = "Winking detected!";
    }

    if (stress > 0.7) {
      analysis = "High stress detected. Try deep breathing.";
    } else if (stress > 0.4) {
      analysis = "Moderate stress. Consider relaxing.";
    }

    return FaceAnalysisResult(
      mood: mood,
      analysisText: analysis,
      smileProb: smileProb,
      stressLevel: stress,
      icon: icon,
      color: color,
    );
  }
}
