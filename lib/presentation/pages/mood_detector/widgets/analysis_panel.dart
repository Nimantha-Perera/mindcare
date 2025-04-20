import 'package:flutter/material.dart';
import '../../../../data/models/face_analysis_result.dart';
import 'metric_card.dart';

class AnalysisPanel extends StatelessWidget {
  final FaceAnalysisResult? result;
  final VoidCallback onAnalyzePressed;
  final bool isAnalyzing;

  const AnalysisPanel({
    Key? key,
    required this.result,
    required this.onAnalyzePressed,
    required this.isAnalyzing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final moodColor = result?.color ?? Colors.grey;
    final moodIcon = result?.icon ?? Icons.face_retouching_natural;
    final moodText = result?.mood ?? 'Not Analyzed';
    final analysisText = result?.analysisText ?? 'Tap "Analyze" to detect your mood';
    final smileProb = result?.smileProb ?? 0.0;
    final stressLevel = result?.stressLevel ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Icon(moodIcon, color: moodColor, size: 50),
            Text(
              moodText,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: moodColor,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: MetricCard(
                    label: "Smile",
                    value: "${(smileProb * 100).toStringAsFixed(1)}%",
                    color: Colors.green,
                    icon: Icons.emoji_emotions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricCard(
                    label: "Stress",
                    value: "${(stressLevel * 100).toStringAsFixed(1)}%",
                    color: Colors.redAccent,
                    icon: Icons.psychology,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: moodColor.withOpacity(0.1),
              ),
              child: Text(
                analysisText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: moodColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: isAnalyzing ? null : onAnalyzePressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: moodColor,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: isAnalyzing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Analyze',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
