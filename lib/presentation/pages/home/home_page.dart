import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindcare/presentation/pages/chatbot/happy_bot_page.dart';
import 'package:mindcare/presentation/pages/home/widgets/home_card.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_musics/relax_musics_page.dart';

class HomePage extends StatelessWidget {
  final String userName = "Nimantha"; // Replace with dynamic user data

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
      body: SafeArea(
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
          },
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
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
          userName,
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
        HomeCardButton(
          label: "Relax My Mind",
          leftIcon: Icons.arrow_forward_ios,
          rightImageAsset: 'assets/icons/mindfulness1.png',
          leftBackgroundColor: const Color(0xFF0057B2),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => RelaxMusicsPage()),
          ),
        ),
        const SizedBox(height: 16),
        HomeCardButton(
          label: "Stress Level",
          leftImageAsset: 'assets/icons/stress_level.png',
          rightIcon: Icons.analytics,
          rightBackgroundColor: const Color(0xFF008450),
          onTap: () => _showSnack(context, "Opening Stress Level"),
        ),
        const SizedBox(height: 16),
        HomeCardButton(
          label: "Happy Bot",
          leftText: "Ask",
          rightImageAsset: 'assets/icons/Bot1.png',
          leftBackgroundColor: const Color(0xFF0057B2),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HappyBotPage()),
          ),
        ),
        const SizedBox(height: 16),
        HomeCardButton(
          label: "Extras",
          leftImageAsset: 'assets/icons/Extra1.png',
          rightIcon: Icons.arrow_forward,
          rightBackgroundColor: const Color(0xFF008450),
          onTap: () => _showSnack(context, "Opening Extras"),
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}
