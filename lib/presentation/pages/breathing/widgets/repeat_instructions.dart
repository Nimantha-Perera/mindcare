import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class RepeatInstructions extends StatelessWidget {
  const RepeatInstructions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120,
          height: 120,
          
          
          child:  Lottie.asset(
                'assets/icons/breathing_icons/repeat.json',
               
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
        ),
        const SizedBox(height: 40),
        const Text(
          "Do this breathing cycle 4–5 times. Stay relaxed and don't rush it. Let each breath become smoother and deeper.",
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