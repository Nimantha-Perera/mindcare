import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/docter_channel/docter_channel.dart';
import 'package:mindcare/presentation/pages/home/widgets/home_card.dart';
import 'package:mindcare/presentation/pages/sos/sos_page.dart';

class ExtrasDashboard extends StatelessWidget {
  const ExtrasDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),  // Deep green
              Color(0xFF2E7D32),  // Medium green
              Color(0xFF4CAF50).withOpacity(0.8),  // Lighter green
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
                        'Extras',
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
          label: "Channel Doctor",
          leftIcon: Icons.format_quote,
          rightImageAsset: 'assets/icons/mindfulness1.png',
          leftBackgroundColor: const Color(0xFF2E7D32),
          onTap: () => {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DoctorChannelScreen()),
            ),
          }
        ),
        const SizedBox(height: 20),
        HomeCardButton(
          label: "SOS",
          leftImageAsset: 'assets/icons/emergency-call.png',
          rightIcon: Icons.check_circle_outline,
          rightBackgroundColor: const Color.fromARGB(255, 163, 19, 0),
          onTap: () => {
           Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => SOSPage()),
            ),
          }
        ),
        const SizedBox(height: 20),
       
      ],
    );
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}