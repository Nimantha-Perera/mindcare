import 'package:flutter/material.dart';

class InstructionText extends StatelessWidget {
  final String text;
  
  const InstructionText(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 16,
        color: Colors.black87,
        height: 1.4,
      ),
    );
  }
}