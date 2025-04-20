import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewBox extends StatelessWidget {
  final CameraController? controller;
  final Color borderColor;

  const CameraPreviewBox({
    Key? key,
    required this.controller,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 3),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: CameraPreview(controller!),
      ),
    );
  }
}
