import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';

class HomePage extends StatelessWidget {
  final String userName = "Nimantha"; // You can fetch this from user data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          // navigation to mood detector page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FaceDetectionScreen(),
            ),
          );
        },
        child: Icon(Icons.emoji_emotions, color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings icon
              // Updated settings button with tap effect
              Align(
                alignment: Alignment.topRight,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Handle settings tap
                      // You can navigate to settings page or show a modal here
                    },
                    borderRadius:
                        BorderRadius.circular(20), // Circular shape for ripple
                    child: Ink(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child:
                            Icon(Icons.settings_outlined, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Greeting - Made larger and bolder
              Text(
                'Hello Good Morning,',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                userName,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 50),
              // Menu Cards - Styled with more rounded corners and click effects
              _buildClickableCard(
                context,
                leftIcon: Icons.arrow_forward,
                label: "Relax My Mind",
                rightImageAsset: 'assets/icons/mindfulness1.png',
                leftBackgroundColor: Color(0xFF0057B2),
                onTap: () {
                  // Handle Relax My Mind tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening Relax My Mind')),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildClickableCard(
                context,
                leftImageAsset: 'assets/icons/stress_level.png',
                label: "Stress Level",
                rightIcon: Icons.music_note,
                rightBackgroundColor: Color(0xFF008450),
                onTap: () {
                  // Handle Stress Level tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening Stress Level')),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildClickableCard(
                context,
                leftText: "Ask",
                label: "Happy Bot",
                rightImageAsset: 'assets/icons/Bot1.png',
                leftBackgroundColor: Color(0xFF0057B2),
                onTap: () {
                  // Handle Happy Bot tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening Happy Bot')),
                  );
                },
              ),
              SizedBox(height: 16),
              _buildClickableCard(
                context,
                leftImageAsset: 'assets/icons/Extra1.png',
                label: "Extras",
                rightIcon: Icons.arrow_forward,
                rightBackgroundColor: Color(0xFF008450),
                onTap: () {
                  // Handle Extras tap
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Opening Extras')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClickableCard(
    BuildContext context, {
    IconData? leftIcon,
    String? leftText,
    required String label,
    IconData? rightIcon,
    String? leftImageAsset,
    String? rightImageAsset,
    Color leftBackgroundColor = Colors.grey,
    Color rightBackgroundColor = Colors.grey,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        splashColor: Colors.grey.withOpacity(0.3),
        highlightColor: Colors.grey.withOpacity(0.1),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Left Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: leftIcon != null || leftText != null
                        ? leftBackgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: leftIcon != null
                        ? Icon(leftIcon, color: Colors.white, size: 24)
                        : leftText != null
                            ? Text(
                                leftText,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              )
                            : leftImageAsset != null
                                ? Image.asset(leftImageAsset, height: 52)
                                : null,
                  ),
                ),
                SizedBox(width: 16),
                // Label
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Right Circle
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: rightIcon != null
                        ? rightBackgroundColor
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: rightIcon != null
                        ? Icon(rightIcon, color: Colors.white, size: 24)
                        : rightImageAsset != null
                            ? Image.asset(rightImageAsset, height: 52)
                            : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Original _buildCard method preserved for reference
  Widget _buildCard(
    BuildContext context, {
    IconData? leftIcon,
    String? leftText,
    required String label,
    IconData? rightIcon,
    String? leftImageAsset,
    String? rightImageAsset,
    Color leftBackgroundColor = Colors.grey,
    Color rightBackgroundColor = Colors.grey,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Left Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: leftIcon != null || leftText != null
                    ? leftBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: leftIcon != null
                    ? Icon(leftIcon, color: Colors.white, size: 24)
                    : leftText != null
                        ? Text(
                            leftText,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          )
                        : leftImageAsset != null
                            ? Image.asset(leftImageAsset, height: 28)
                            : null,
              ),
            ),
            SizedBox(width: 16),
            // Label
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            // Right Circle
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: rightIcon != null
                    ? rightBackgroundColor
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: rightIcon != null
                    ? Icon(rightIcon, color: Colors.white, size: 24)
                    : rightImageAsset != null
                        ? Image.asset(rightImageAsset, height: 32)
                        : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
