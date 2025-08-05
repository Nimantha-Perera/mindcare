import 'package:flutter/material.dart';

class TypingIndicator extends StatefulWidget {
  final String botName;
  final Color bubbleColor;
  final Color textColor;
  
  const TypingIndicator({
    Key? key, 
    required this.botName,
    this.bubbleColor = const Color(0xFFECF3FD),
    this.textColor = const Color(0xFF0066CC),
  }) : super(key: key);

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0, end: 6).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(index * 0.2, 0.6 + index * 0.2, curve: Curves.easeOut),
        ),
      );
    });
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 70, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot avatar
          Container(
            width: 36,
            height: 36,
            margin: const EdgeInsets.only(right: 8, top: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF008F76),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.psychology,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bot name
                Padding(
                  padding: const EdgeInsets.only(left: 12, bottom: 2),
                  child: Text(
                    widget.botName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                
                // Typing bubble with animated dots
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: widget.bubbleColor,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) {
                          return Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: widget.textColor,
                              shape: BoxShape.circle,
                            ),
                            transform: Matrix4.translationValues(
                              0, 
                              -_dotAnimations[index].value, 
                              0,
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}