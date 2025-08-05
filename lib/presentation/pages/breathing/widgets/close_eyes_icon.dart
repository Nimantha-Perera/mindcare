import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ClosedEyesIcon extends StatelessWidget {
  const ClosedEyesIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Center(
        child: Lottie.asset(
          'assets/icons/breathing_icons/close_eye.json',
          width: 200,
          height: 200,
          fit: BoxFit.contain,
          repeat: false
        ),
      ),
    );
  }
}