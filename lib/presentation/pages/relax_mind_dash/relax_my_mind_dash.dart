import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/breathing/breathing.dart';
import 'package:mindcare/presentation/pages/home/widgets/home_card.dart';
import 'package:mindcare/presentation/routes/app_routes.dart';

import '../relax_musics/relax_musics_page.dart';

class RelaxMyMindDashboard extends StatelessWidget {
  const RelaxMyMindDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A237E),
              Color(0xFF0D47A1),
              Color(0xFF2196F3).withOpacity(0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.2),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Center(
                      child: Text(
                        'Relax My Mind',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Centered cards
                    Expanded(
                      child: Center(
                        child: _buildCardList(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeCardButton(
          label: "Breathing",
          leftIcon: Icons.air,
          rightImageAsset: 'assets/icons/mindfulness1.png',
          leftBackgroundColor: const Color(0xFF0057B2),
          onTap: () => {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MeditationGuide()),),
          }
        ),
        const SizedBox(height: 20),
        HomeCardButton(
          label: "Relax Music",
          leftImageAsset: 'assets/icons/sound.png',
          rightIcon: Icons.headphones,
          rightBackgroundColor: const Color(0xFF008450),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => RelaxMusicsPage()),),
            
          }
        ),
        const SizedBox(height: 20),
        HomeCardButton(
          label: "Relax Mind Tips",
          leftIcon: Icons.tips_and_updates,
          rightImageAsset: 'assets/icons/lamp.png',
          leftBackgroundColor: const Color(0xFF0057B2),
          onTap: () => {
             Navigator.pushNamed(context, AppRoutes.stressTipsPage)
          }
        ),
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.indigo.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}