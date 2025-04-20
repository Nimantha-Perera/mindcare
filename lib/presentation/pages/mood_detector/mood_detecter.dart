import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:mindcare/core/utils/mood_utill.dart';
import 'package:mindcare/presentation/pages/mood_detector/widgets/analysis_panel.dart';
import 'package:mindcare/presentation/pages/mood_detector/widgets/camera_preview_box.dart';
import '../../../data/models/face_analysis_result.dart';



class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  bool _isProcessing = false;
  bool _hasAnalyzed = false;

  FaceAnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.front,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _analyzeFace() async {
    if (_isProcessing || _hasAnalyzed || _cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isProcessing = true;
    });

    final file = await _captureImage();
    if (file != null) {
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector!.processImage(inputImage);
      _processFaces(faces);
      await file.delete();
    }

    setState(() {
      _hasAnalyzed = true;
      _isProcessing = false;
    });
  }

  Future<File?> _captureImage() async {
    try {
      final image = await _cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      debugPrint('Error capturing image: $e');
      return null;
    }
  }

  void _processFaces(List<Face> faces) {
    if (faces.isEmpty) {
      setState(() {
        _analysisResult = FaceAnalysisResult(
          mood: 'No Face',
          icon: Icons.face_outlined,
          color: Colors.grey,
          smileProb: 0.0,
          stressLevel: 0.0,
          analysisText: 'No face detected. Try again.',
        );
      });
      return;
    }

    final face = faces.first;
    final smileProb = face.smilingProbability ?? 0.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final leftEye = face.leftEyeOpenProbability ?? 1.0;

    final sadness = 1.0 - smileProb;
    final eyeStress = ((rightEye + leftEye) / 2.0) * 0.5;
    final stress = (sadness * 0.7 + eyeStress * 0.3).clamp(0.0, 1.0);

    String mood = 'Neutral';

    if (smileProb > 0.6) {
      mood = 'Very Happy';
    } else if (smileProb > 0.3) {
      mood = 'Happy';
    } else if (sadness > 0.7) {
      mood = 'Sad';
    } else if (sadness > 0.5) {
      mood = 'A Little Sad';
    }

    if (rightEye < 0.5 && leftEye < 0.5) {
      mood = 'Eyes Closed';
    } else if (rightEye < 0.5 || leftEye < 0.5) {
      mood = 'Winking';
    }

    setState(() {
      _analysisResult = FaceAnalysisResult(
        mood: mood,
        icon: MoodUtils.getMoodIcon(mood),
        color: MoodUtils.getMoodColor(mood),
        smileProb: smileProb,
        stressLevel: stress,
        analysisText: MoodUtils.getAnalysisText(mood, stress),
      );
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _analysisResult?.color ?? Colors.grey;

    return Scaffold(
      backgroundColor: moodColor.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: moodColor,
        title: const Text("Mood & Stress Detection"),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: CameraPreviewBox(
                    controller: _cameraController,
                    borderColor: moodColor,
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: AnalysisPanel(
                    result: _analysisResult,
                    onAnalyzePressed: _analyzeFace,
                    isAnalyzing: _isProcessing,
                  ),
                ),
              ],
            ),
    );
  }
}
