import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class FinalInstructions extends StatelessWidget {
  const FinalInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.blue.shade100,
            shape: BoxShape.circle,
          ),
          child:  Lottie.asset(
                'assets/icons/breathing_icons/finale.json',
    
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
        ),
        const SizedBox(height: 40),
        const Text(
          "After a few rounds, just sit for a moment. Notice how your body feels. Try to keep your mind on the moment, and let go of any stressful thoughts.",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}