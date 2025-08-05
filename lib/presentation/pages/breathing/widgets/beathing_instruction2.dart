import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/breathing/breathing.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/beathing_icon.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/instruction_txt.dart';


class BreathingInstructions extends StatelessWidget {
  const BreathingInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const BreathingIcon(),
        const SizedBox(height: 40),
        const Column(
          children: [
            InstructionText("Inhale through your nose for 4 seconds"),
            SizedBox(height: 12),
            InstructionText("Hold your breath for 7 seconds"),
            SizedBox(height: 12),
            InstructionText("Exhale slowly through your mouth for 8 seconds"),
          ],
        ),
      ],
    );
  }
}