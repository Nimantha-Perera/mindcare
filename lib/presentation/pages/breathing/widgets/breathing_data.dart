import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mindcare/domain/models/breathing.dart';
import 'package:mindcare/presentation/pages/breathing/breathing.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/beathing_icon.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/beathing_instruction2.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/breathing_poster_instructions.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/close_eyes_icon.dart';



import '../widgets/repeat_instructions.dart';
import '../widgets/final_instructions.dart';

class MeditationData {
  static List<MeditationStep> getSteps() {
    return [
      MeditationStep(
        stepNumber: 1,
        title: "Choose a comfortable place",
        subtitle: "A quiet environment without noise is best.",
        customContent: Lottie.asset(
          'assets/icons/breathing_icons/location.json', // Local poster animation file
          width: 200,
          height: 200,
        ),
        backgroundColor: Colors.teal.shade100,
        showOnlyNext: true,
      ),
      MeditationStep(
        stepNumber: 2,
        title: "",
        subtitle: "",
        customContent: const PostureInstructions(),
        showOnlyNext: false,
      ),
      MeditationStep(
        stepNumber: 3,
        title: "Close Your eyes",
        subtitle: "",
        customContent: const ClosedEyesIcon(),
        showOnlyNext: false,
      ),
      MeditationStep(
        stepNumber: 4,
        title: "Focus on Your Breathing",
        subtitle: "",
         customContent: Lottie.asset(
          'assets/icons/breathing_icons/penahalu.json', // Local poster animation file
          width: 200,
          height: 200,
        ),
        showOnlyNext: false,
      ),
      MeditationStep(
        stepNumber: 5,
        title: "Start the 4-7-8 Breathing Technique",
        subtitle: "",
        customContent: const BreathingInstructions(),
        showOnlyNext: false,
      ),
      MeditationStep(
        stepNumber: 5,
        title: "Repeat the Cycle",
        subtitle: "",
        customContent: const RepeatInstructions(),
        showOnlyNext: false,
      ),
      MeditationStep(
        stepNumber: 6,
        title: "Stay Present and Calm",
        subtitle: "",
        customContent: const FinalInstructions(),
        showOnlyNext: false,
        isLast: true,
      ),
    ];
  }
}