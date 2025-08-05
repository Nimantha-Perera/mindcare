import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/quiz_modal.dart';
import 'package:mindcare/presentation/pages/stress_level/util/stress_calculater.dart';

class ResultsScreen extends StatelessWidget {
  final StressResult stressResult;
  final VoidCallback onRestart;

  const ResultsScreen({
    Key? key,
    required this.stressResult,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final Color stressColor = StressCalculator.getStressColor(stressResult.percentage);
    
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 16.0 : 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isSmallScreen ? 20 : 30),
                
                // Results header
                Text(
                  'Your Stress Level Results',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 22 : 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                
                SizedBox(height: isSmallScreen ? 20 : 30),
                
                // Main stress level card
                _buildStressLevelCard(context, stressColor, isSmallScreen),
                
                SizedBox(height: isSmallScreen ? 20 : 30),
                
                // Score breakdown card
                _buildScoreBreakdownCard(stressColor, isSmallScreen),
                
                SizedBox(height: isSmallScreen ? 20 : 30),
                
                // Stress relief tips (if needed)
                if (stressResult.percentage > 40)
                  _buildStressReliefTips(isSmallScreen),
                
                SizedBox(height: isSmallScreen ? 30 : 40),
                
                // Restart button
                _buildRestartButton(isSmallScreen),
                
                SizedBox(height: isSmallScreen ? 20 : 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStressLevelCard(BuildContext context, Color stressColor, bool isSmallScreen) {
    final circularSize = isSmallScreen ? 120.0 : 150.0;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 20 : 30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular progress indicator
          SizedBox(
            height: circularSize,
            width: circularSize,
            child: Stack(
              children: [
                SizedBox(
                  height: circularSize,
                  width: circularSize,
                  child: CircularProgressIndicator(
                    value: stressResult.percentage / 100,
                    strokeWidth: isSmallScreen ? 10 : 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(stressColor),
                  ),
                ),
                Positioned.fill(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${stressResult.percentage.round()}%',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.bold,
                            color: stressColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          stressResult.level,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            fontWeight: FontWeight.w600,
                            color: stressColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 15 : 20),
          
          Text(
            stressResult.level,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 22,
              fontWeight: FontWeight.bold,
              color: stressColor,
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 10 : 15),
          
          Text(
            stressResult.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBreakdownCard(Color stressColor, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Score Breakdown',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            'Your score: ${stressResult.score} out of ${stressResult.maxScore}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Stress percentage: ${stressResult.percentage.round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: stressColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStressReliefTips(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 15),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Colors.blue[700],
            size: isSmallScreen ? 20 : 24,
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Quick Stress Relief Tips',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            '• Take deep breaths (4 seconds in, 6 seconds out)\n'
            '• Go for a 10-minute walk\n'
            '• Practice mindfulness or meditation\n'
            '• Talk to a friend or family member\n'
            '• Listen to calming music',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestartButton(bool isSmallScreen) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRestart,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            vertical: isSmallScreen ? 12 : 15,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 2,
        ),
        child: Text(
          'Take Quiz Again',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
    );
  }
}