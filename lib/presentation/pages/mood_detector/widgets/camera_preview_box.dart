import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:ui';

class CameraPreviewBox extends StatefulWidget {
  final CameraController? controller;
  final Color borderColor;
  final double size;
  final bool showFocusCircle;
  final bool enableEffects;

  const CameraPreviewBox({
    Key? key,
    required this.controller,
    this.borderColor = const Color(0xFF4A90E2),
    this.size = 320,
    this.showFocusCircle = true,
    this.enableEffects = true,
  }) : super(key: key);

  @override
  State<CameraPreviewBox> createState() => _CameraPreviewBoxState();
}

class _CameraPreviewBoxState extends State<CameraPreviewBox> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _focusing = false;
  Offset? _focusPoint;

  @override
  void initState() {
    super.initState();
    
    // Set up pulse animation for focus effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _pulseController.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _focusing = false;
          _focusPoint = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleTapToFocus(TapDownDetails details, BoxConstraints constraints) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) return;
    
    // Calculate focus point relative to camera preview
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset localPoint = box.globalToLocal(details.globalPosition);
    
    final double x = localPoint.dx / constraints.maxWidth;
    final double y = localPoint.dy / constraints.maxHeight;
    
    // Set focus point in camera controller
    widget.controller!.setFocusPoint(Offset(x, y));
    
    // Show focusing animation
    setState(() {
      _focusing = true;
      _focusPoint = localPoint;
      _pulseController.forward(from: 0.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.borderColor.withOpacity(0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Camera preview or loading indicator
                _buildCameraPreview(),
                
                // Decorative border
                _buildBorder(),
                
                // Focus indicator (if enabled)
                if (widget.showFocusCircle && _focusing && _focusPoint != null)
                  _buildFocusIndicator(),
                
                // Tap detector for focus
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) => _handleTapToFocus(details, constraints),
                    behavior: HitTestBehavior.translucent,
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildCameraPreview() {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 50,
                height: 50, 
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 16),
              Text(
                "Initializing camera...",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ClipOval(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Actual camera preview
          CameraPreview(widget.controller!),
          
          // Visual effects overlay (if enabled)
          if (widget.enableEffects)
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                  ],
                  stops: const [0.7, 1.0],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBorder() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: _focusing 
              ? widget.borderColor.withOpacity(0.9)
              : widget.borderColor.withOpacity(0.6),
          width: _focusing ? 3.0 : 2.0,
        ),
      ),
    );
  }

  Widget _buildFocusIndicator() {
    return Positioned(
      left: _focusPoint!.dx - 30,
      top: _focusPoint!.dy - 30,
      child: ScaleTransition(
        scale: _pulseAnimation,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
      ),
    );
  }
}