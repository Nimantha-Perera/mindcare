import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/presentation/pages/chatbot/happy_bot_page.dart';
import 'package:mindcare/presentation/pages/extrass_dash/extrass_dash.dart';
import 'package:mindcare/presentation/pages/home/widgets/home_card.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_mind_dash/relax_my_mind_dash.dart';
import 'package:mindcare/presentation/pages/relax_musics/relax_musics_page.dart';
import 'package:mindcare/presentation/pages/setting/settings.dart';
import 'package:mindcare/presentation/pages/stress_level/screens/stress_level_quiz.dart';

class HomePage extends StatelessWidget {

 final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => FaceDetectionScreen()),
          );
        },
        child: const Icon(Icons.emoji_emotions, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Beautiful white backdrop with subtle patterns
          Positioned.fill(
            child: CustomPaint(
              painter: BackdropPainter(),
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSettingsButton(context),
                  const SizedBox(height: 20),
                  _buildGreeting(),
                  const SizedBox(height: 50),
                  _buildCardList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to settings or show modal
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SettingsScreen()),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.settings_outlined, color: Colors.grey),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hello Good Morning,',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          user != null ? user!.displayName! : 'User',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildCardList(BuildContext context) {
    return Column(
      children: [
        _buildElevatedCard(
          child: HomeCardButton(
            label: "Relax My Mind",
            leftIcon: Icons.arrow_forward_ios,
            rightImageAsset: 'assets/icons/mindfulness1.png',
            leftBackgroundColor: const Color(0xFF0057B2),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RelaxMyMindDashboard()),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildElevatedCard(
          child: HomeCardButton(
            label: "Stress Level",
            leftImageAsset: 'assets/icons/stress_level.png',
            rightIcon: Icons.analytics,
            rightBackgroundColor: const Color(0xFF008450),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StressLevelQuiz()),
              ),
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildElevatedCard(
          child: HomeCardButton(
            label: "Happy Bot",
            leftText: "Ask",
            rightImageAsset: 'assets/icons/Bot1.png',
            leftBackgroundColor: const Color(0xFF0057B2),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HappyBotPage()),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildElevatedCard(
          child: HomeCardButton(
            label: "Extras",
            leftImageAsset: 'assets/icons/Extra1.png',
            rightIcon: Icons.arrow_forward,
            rightBackgroundColor: const Color(0xFF008450),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ExtrasDashboard()),
            ),
          ),
        ),
      ],
    );
  }

  // Helper widget to add elevation and shadow to cards
  Widget _buildElevatedCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

// Custom painter for beautiful backdrop
class BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base white background
    Paint backgroundPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    // Create subtle pattern
    Paint patternPaint = Paint()
      ..color = Colors.grey.shade100
      ..style = PaintingStyle.fill;

    // Draw subtle circles in top-left
    for (int i = 0; i < 5; i++) {
      double radius = 80 + i * 30;
      canvas.drawCircle(
        Offset(-radius / 2, -radius / 2),
        radius,
        patternPaint,
      );
    }

    // Draw subtle circles in bottom-right
    Paint bottomPatternPaint = Paint()
      ..color = Colors.blue.shade50.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < 3; i++) {
      double radius = 100 + i * 40;
      canvas.drawCircle(
        Offset(size.width + radius / 3, size.height + radius / 3),
        radius,
        bottomPatternPaint,
      );
    }

    // Add some soft curved lines
    Paint linePaint = Paint()
      ..color = Colors.grey.shade50
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;

    Path path = Path();
    path.moveTo(size.width * 0.8, 0);
    path.quadraticBezierTo(
      size.width * 0.2, size.height * 0.3,
      size.width * 0.7, size.height * 0.5
    );
    canvas.drawPath(path, linePaint);
    
    Path path2 = Path();
    path2.moveTo(0, size.height * 0.7);
    path2.quadraticBezierTo(
      size.width * 0.5, size.height * 0.8,
      size.width * 0.3, size.height
    );
    canvas.drawPath(path2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}