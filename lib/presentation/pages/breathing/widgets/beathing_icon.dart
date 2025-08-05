import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BreathingIcon extends StatefulWidget {
  const BreathingIcon({super.key});

  @override
  State<BreathingIcon> createState() => _BreathingIconState();
}

class _BreathingIconState extends State<BreathingIcon>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
    

    _lottieController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
 
              Lottie.asset(
                'assets/icons/breathing_icons/breth.json',
                controller: _lottieController,
                width: 200,
                height: 200,
                fit: BoxFit.contain,
                repeat: true,
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Breathing instruction text
        // AnimatedBuilder(
        //   animation: _breathingController,
        //   builder: (context, child) {
        //     return Opacity(
        //       opacity: 0.7 + (0.3 * _breathingController.value),
        //       child: const Text(
        //         'Breathe In... Breathe Out...',
        //         style: TextStyle(
        //           fontSize: 18,
        //           fontWeight: FontWeight.w500,
        //           color: Colors.blueGrey,
        //         ),
        //         textAlign: TextAlign.center,
        //       ),
        //     );
        //   },
        // ),
      ],
    );
  }
}