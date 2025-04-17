import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

class FaceDetectionScreen extends StatefulWidget {
  @override
  _FaceDetectionScreenState createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  List<CameraDescription> _cameras = [];
  bool _isDetecting = false;

  String _currentMood = "No face detected";
  double _smileProb = 0.0;
  Color _moodColor = Colors.grey;
  IconData _moodIcon = Icons.face_outlined;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final frontCamera = _cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras.first,
      );

      _cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {});
        _startImageStream();
      }
    } catch (e) {
      print("Error initializing camera: $e");
    }
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      minFaceSize: 0.1,
    );
    _faceDetector = GoogleMlKit.vision.faceDetector(options);
  }

  void _startImageStream() {
    _cameraController!.startImageStream((CameraImage image) async {
      if (_isDetecting) return;

      _isDetecting = true;
      try {
        final inputImage = await _processImage(image);
        if (inputImage != null) {
          final faces = await _faceDetector!.processImage(inputImage);
          _analyzeDetectedFaces(faces);
        }
      } catch (e) {
        print('Error during face detection: $e');
      } finally {
        _isDetecting = false;
      }
    });
  }

Future<InputImage?> _processImage(CameraImage image) async {
  try {
    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    final Size imageSize = Size(
      image.width.toDouble(),
      image.height.toDouble(),
    );

    final camera = _cameras.first;
    final rotation = InputImageRotationValue.fromRawValue(camera.sensorOrientation) 
      ?? InputImageRotation.rotation0deg;

    final inputImage = InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: imageSize,
        rotation: rotation,
        format: InputImageFormat.yuv_420_888, // use correct format
        bytesPerRow: image.planes[0].bytesPerRow,
        
      ),
    );

    return inputImage;
  } catch (e) {
    print('Error processing image: $e');
    return null;
  }
}


  void _analyzeDetectedFaces(List<Face> faces) {
    if (faces.isEmpty) {
      setState(() {
        _currentMood = "No face detected";
        _moodColor = Colors.grey;
        _moodIcon = Icons.face_outlined;
        _smileProb = 0.0;
      });
      return;
    }

    final face = faces.first;
    final smileProb = face.smilingProbability ?? 0.0;

    String mood;
    Color color;
    IconData icon;

    if (smileProb < 0.1) {
      mood = "Neutral";
      color = Colors.amber;
      icon = Icons.sentiment_neutral;
    } else if (smileProb < 0.3) {
      mood = "Slight Smile";
      color = Colors.lightGreen;
      icon = Icons.sentiment_satisfied;
    } else if (smileProb < 0.7) {
      mood = "Happy";
      color = Colors.green;
      icon = Icons.sentiment_very_satisfied;
    } else {
      mood = "Very Happy";
      color = Colors.green.shade700;
      icon = Icons.sentiment_very_satisfied;
    }

    final rightEyeOpen = face.rightEyeOpenProbability ?? 1.0;
    final leftEyeOpen = face.leftEyeOpenProbability ?? 1.0;

    if (rightEyeOpen < 0.5 && leftEyeOpen < 0.5) {
      mood = "Eyes Closed";
      color = Colors.purple;
      icon = Icons.visibility_off;
    } else if (rightEyeOpen < 0.5 || leftEyeOpen < 0.5) {
      mood = "Winking";
      color = Colors.orange;
      icon = Icons.face_retouching_natural;
    }

    setState(() {
      _currentMood = mood;
      _moodColor = color;
      _moodIcon = icon;
      _smileProb = smileProb;
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
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Mood Detection'),
        backgroundColor: _moodColor,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: CameraPreview(_cameraController!),
          ),
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              color: Colors.white,
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_moodIcon, size: 80, color: _moodColor),
                  SizedBox(height: 16),
                  Text(
                    _currentMood,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _moodColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: _smileProb,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(_moodColor),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Smile Score: ${(_smileProb * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
