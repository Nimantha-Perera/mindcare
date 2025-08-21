import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mindcare/core/utils/mood_utill.dart';
import 'package:mindcare/presentation/pages/mood_detector/widgets/analysis_panel.dart';
import 'package:mindcare/presentation/pages/mood_detector/widgets/camera_preview_box.dart';
import '../../../data/models/face_analysis_result.dart';

enum AnalysisMode { camera, image }

class FaceDetectionScreen extends StatefulWidget {
  const FaceDetectionScreen({Key? key}) : super(key: key);

  @override
  State<FaceDetectionScreen> createState() => _FaceDetectionScreenState();
}

class _FaceDetectionScreenState extends State<FaceDetectionScreen> {
  CameraController? _cameraController;
  FaceDetector? _faceDetector;
  final ImagePicker _imagePicker = ImagePicker();

  bool _isProcessing = false;
  bool _hasAnalyzed = false;
  AnalysisMode _currentMode = AnalysisMode.camera;
  File? _selectedImage;

  FaceAnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _initializeFaceDetector();
  }

  Future<void> _initializeCamera() async {
    try {
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
    } catch (e) {
      debugPrint('Error initializing camera: $e');
    }
  }

  void _initializeFaceDetector() {
    final options = FaceDetectorOptions(
      enableClassification: true,
      minFaceSize: 0.1,
    );
    _faceDetector = FaceDetector(options: options);
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _currentMode = AnalysisMode.image;
          _hasAnalyzed = false;
          _analysisResult = null;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      _showErrorSnackBar('Failed to pick image. Please try again.');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _currentMode = AnalysisMode.image;
          _hasAnalyzed = false;
          _analysisResult = null;
        });
      }
    } catch (e) {
      debugPrint('Error taking photo: $e');
      _showErrorSnackBar('Failed to take photo. Please try again.');
    }
  }

  void _switchToCamera() {
    setState(() {
      _currentMode = AnalysisMode.camera;
      _selectedImage = null;
      _hasAnalyzed = false;
      _analysisResult = null;
    });
  }

  Future<void> _analyzeFace() async {
    if (_isProcessing || _hasAnalyzed) return;

    if (_currentMode == AnalysisMode.camera && 
        (_cameraController == null || !_cameraController!.value.isInitialized)) {
      _showErrorSnackBar('Camera not ready. Please wait.');
      return;
    }

    if (_currentMode == AnalysisMode.image && _selectedImage == null) {
      _showErrorSnackBar('No image selected. Please select an image first.');
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      File? imageFile;
      
      if (_currentMode == AnalysisMode.camera) {
        imageFile = await _captureImage();
      } else {
        imageFile = _selectedImage;
      }

      if (imageFile != null) {
        final inputImage = InputImage.fromFile(imageFile);
        final faces = await _faceDetector!.processImage(inputImage);
        _processFaces(faces);
        
        // Only delete the file if it was captured from camera (temporary file)
        if (_currentMode == AnalysisMode.camera) {
          await imageFile.delete();
        }
      }
    } catch (e) {
      debugPrint('Error analyzing face: $e');
      _showErrorSnackBar('Analysis failed. Please try again.');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Select Image Source',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildImageSourceButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _takePhoto();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.blue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? Colors.blue : Colors.grey[300]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _faceDetector?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final moodColor = _analysisResult?.color ?? Colors.blue;

    return Scaffold(
      backgroundColor: moodColor.withOpacity(0.05),
      appBar: AppBar(
        backgroundColor: moodColor,
        title: const Text("Mood & Stress Detection"),
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library),
            onPressed: _showImagePickerBottomSheet,
            tooltip: 'Upload Image',
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Selection
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _buildModeButton(
                  icon: Icons.camera_alt,
                  label: 'Live Camera',
                  isActive: _currentMode == AnalysisMode.camera,
                  onTap: _switchToCamera,
                ),
                const SizedBox(width: 8),
                _buildModeButton(
                  icon: Icons.image,
                  label: 'Upload Image',
                  isActive: _currentMode == AnalysisMode.image,
                  onTap: _showImagePickerBottomSheet,
                ),
              ],
            ),
          ),
          
          // Content Area
          Expanded(
            flex: 3,
            child: _buildContentArea(moodColor),
          ),
          
          // Analysis Panel
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

  Widget _buildContentArea(Color moodColor) {
    if (_currentMode == AnalysisMode.image) {
      return _selectedImage != null
          ? Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: moodColor, width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.file(
                  _selectedImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            )
          : Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[300]!, width: 2),
                color: Colors.grey[50],
              ),
              child: InkWell(
                onTap: _showImagePickerBottomSheet,
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Tap to select an image',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            );
    } else {
      return _cameraController == null || !_cameraController!.value.isInitialized
          ? const Center(child: CircularProgressIndicator())
          : CameraPreviewBox(
              controller: _cameraController,
              borderColor: moodColor,
            );
    }
  }
}