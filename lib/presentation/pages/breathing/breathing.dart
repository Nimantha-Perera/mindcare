import 'package:flutter/material.dart';
import 'package:mindcare/domain/models/breathing.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/breathing_data.dart';

class MeditationGuide extends StatefulWidget {
  const MeditationGuide({Key? key}) : super(key: key);

  @override
  State<MeditationGuide> createState() => _MeditationGuideState();
}

class _MeditationGuideState extends State<MeditationGuide> {
  int currentStep = 0;
  late List<MeditationStep> steps;

  @override
  void initState() {
    super.initState();
    steps = MeditationData.getSteps();
  }

  void nextStep() {
    if (currentStep < steps.length - 1) {
      setState(() {
        currentStep++;
      });
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  void restart() {
    setState(() {
      currentStep = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final step = steps[currentStep];
    
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Step indicator
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Text(
                  'STEP ${step.stepNumber}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              
              // Content area
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (step.customContent != null)
                      step.customContent!
                    else
                      _buildDefaultContent(step),
                    
                    const SizedBox(height: 40),
                    
                    if (step.title.isNotEmpty) ...[
                      Text(
                        step.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (step.subtitle.isNotEmpty)
                      Text(
                        step.subtitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Navigation buttons
              Row(
                children: [
                  if (!step.showOnlyNext)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Back',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  
                  if (!step.showOnlyNext) const SizedBox(width: 16),
                  
                  Expanded(
                    child: ElevatedButton(
                      onPressed: step.isLast ? restart : nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Text(
                        step.isLast ? 'Restart' : 'Next',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultContent(MeditationStep step) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: step.backgroundColor ?? Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        step.icon ?? Icons.favorite,
        size: 80,
        color: step.iconColor ?? Colors.grey,
      ),
    );
  }
}