import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;

  bool _processingImage = false;
  bool _hasAnalyzed = false;

  String _currentMood = "Not Analyzed";
  String _analysisText = "Tap 'Analyze' to detect your mood";
  double _smileProb = 0.0;
  double _stressLevel = 0.0;

  Color _moodColor = Colors.grey;
  IconData _moodIcon = Icons.face_retouching_natural;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
    );
    _faceDetector = GoogleMlKit.vision.faceDetector(options);
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first);

    _cameraController = CameraController(
      frontCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _analyzeOncePressed() async {
    if (_processingImage || _hasAnalyzed || _cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _processingImage = true;
      _analysisText = "Analyzing...";
    });

    final file = await _takePicture();
    if (file != null) {
      final inputImage = InputImage.fromFile(file);
      final faces = await _faceDetector!.processImage(inputImage);
      _analyzeDetectedFaces(faces);
      await file.delete();
    }

    setState(() {
      _hasAnalyzed = true;
      _processingImage = false;
    });
  }

  Future<File?> _takePicture() async {
    try {
      final image = await _cameraController!.takePicture();
      return File(image.path);
    } catch (e) {
      debugPrint('Error taking picture: $e');
      return null;
    }
  }

  void _analyzeDetectedFaces(List<Face> faces) {
    if (faces.isEmpty) {
      setState(() {
        _currentMood = "No Face";
        _analysisText = "No face detected. Try again.";
        _moodColor = Colors.grey;
        _moodIcon = Icons.face_outlined;
        _smileProb = 0.0;
        _stressLevel = 0.0;
      });
      return;
    }

    final face = faces.first;
    final smileProb = face.smilingProbability ?? 0.0;
    final rightEye = face.rightEyeOpenProbability ?? 1.0;
    final leftEye = face.leftEyeOpenProbability ?? 1.0;

    final sadness = 1.0 - smileProb;
    final eyeStress = ((rightEye + leftEye) / 2.0) * 0.5;
    double stress = (sadness * 0.7 + eyeStress * 0.3).clamp(0.0, 1.0);

    String mood = "Neutral";
    IconData icon = Icons.sentiment_neutral;
    Color color = Colors.amber;
    String analysis = "You seem balanced and calm.";

    if (smileProb > 0.6) {
      mood = "Very Happy";
      icon = Icons.sentiment_very_satisfied;
      color = Colors.green.shade700;
      analysis = "You're glowing with happiness!";
    } else if (smileProb > 0.3) {
      mood = "Happy";
      icon = Icons.sentiment_satisfied;
      color = Colors.green;
      analysis = "You look cheerful!";
    } else if (sadness > 0.7) {
      mood = "Sad";
      icon = Icons.sentiment_very_dissatisfied;
      color = Colors.blue.shade700;
      analysis = "You seem down. Try relaxing or talking to someone.";
    } else if (sadness > 0.5) {
      mood = "A Little Sad";
      icon = Icons.sentiment_dissatisfied;
      color = Colors.blue;
      analysis = "Take a short walk or rest.";
    }

    if (rightEye < 0.5 && leftEye < 0.5) {
      mood = "Eyes Closed";
      icon = Icons.visibility_off;
      color = Colors.purple;
      analysis = "Eyes closed – maybe resting?";
    } else if (rightEye < 0.5 || leftEye < 0.5) {
      mood = "Winking";
      icon = Icons.face_retouching_natural;
      color = Colors.orange;
      analysis = "Winking detected!";
    }

    if (stress > 0.7) {
      analysis = "High stress detected. Try deep breathing.";
    } else if (stress > 0.4) {
      analysis = "Moderate stress. Consider relaxing.";
    }

    setState(() {
      _currentMood = mood;
      _moodIcon = icon;
      _moodColor = color;
      _smileProb = smileProb;
      _stressLevel = stress;
      _analysisText = analysis;
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
    return Scaffold(
      backgroundColor: _moodColor.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: _moodColor,
        title: const Text("Mood & Stress Detection"),
      ),
      body: _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _moodColor, width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CameraPreview(_cameraController!),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 10,
                          color: Colors.black.withOpacity(0.1),
                          offset: const Offset(0, -5),
                        )
                      ],
                    ),
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          Icon(_moodIcon, color: _moodColor, size: 50),
                          Text(
                            _currentMood,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: _moodColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _metricCard("Smile", "${(_smileProb * 100).toStringAsFixed(1)}%", Colors.green, Icons.emoji_emotions),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _metricCard("Stress", "${(_stressLevel * 100).toStringAsFixed(1)}%", Colors.redAccent, Icons.psychology),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: _moodColor.withOpacity(0.1),
                            ),
                            child: Text(
                              _analysisText,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: _moodColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _analyzeOncePressed,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _moodColor,
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Analyze',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _metricCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 6),
              Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          )
        ],
      ),
    );
  }
}
