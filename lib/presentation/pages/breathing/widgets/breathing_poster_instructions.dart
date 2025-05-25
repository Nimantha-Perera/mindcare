import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mindcare/presentation/pages/breathing/breathing.dart';
import 'package:mindcare/presentation/pages/breathing/widgets/instruction_txt.dart';

class PostureInstructions extends StatelessWidget {
  const PostureInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Meditation person illustration
        Container(
          width: 250,
          height: 250,
         
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Decorative elements
             
              // Person meditating
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Head
                  Lottie.asset(
                    'assets/icons/breathing_icons/bawana.json', // Local poster animation file
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Instructions
        const Column(
          children: [
            InstructionText(
                "Sit in a chair or on the floor with your back straight"),
            SizedBox(height: 12),
            InstructionText("Rest your hands on your lap or knees"),
            SizedBox(height: 12),
            InstructionText(
                "Keep your feet flat on the ground (if on a chair)"),
            SizedBox(height: 12),
            InstructionText("Relax your shoulders and jaw"),
          ],
        ),
      ],
    );
  }
}
