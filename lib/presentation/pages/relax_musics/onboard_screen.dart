import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final Color primaryColor = const Color(0xFF00846A);
  final Color lightGrey = Colors.grey.shade300;
  final Color cardColor = const Color(0xFFF8F9FA);

  void _completeOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/relax-musics-page');
    }
  }

  void _skipOnboarding() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/relax-musics-page');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isMobile = screenWidth <= 480;
    final isTablet = screenWidth > 768;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 48.0 : isMobile ? 24.0 : 32.0,
            vertical: isMobile ? 20.0 : 32.0,
          ),
          child: Column(
            children: [
             
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _skipOnboarding,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey.shade600,
                    ),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Logo and title
                        Container(
                          width: isMobile ? 80 : 100,
                          height: isMobile ? 80 : 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: primaryColor.withOpacity(0.1),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            Icons.music_note_rounded,
                            size: isMobile ? 40 : 50,
                            color: primaryColor,
                          ),
                        ),
                        SizedBox(height: isMobile ? 20 : 24),
                        Text(
                          'Welcome to Relax Music',
                          style: TextStyle(
                            fontSize: isMobile ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isMobile ? 8 : 12),
                        Text(
                          'Your peaceful music companion',
                          style: TextStyle(
                            fontSize: isMobile ? 16 : 18,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        SizedBox(height: isMobile ? 40 : 60),

                        // Headphone recommendation card
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(
                            maxWidth: isTablet ? 500 : double.infinity,
                          ),
                          padding: EdgeInsets.all(isMobile ? 24 : 32),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                primaryColor.withOpacity(0.05),
                                primaryColor.withOpacity(0.02),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                            border: Border.all(
                              color: primaryColor.withOpacity(0.2),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primaryColor.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                           
                              Container(
                                width: isMobile ? 120 : 150,
                                height: isMobile ? 120 : 150,
                                child: Lottie.asset(
                                  'assets/icons/breathing_icons/headset.json',
                                  repeat: true,
                                  reverse: false,
                                  animate: true,
                                ),
                              ),
                              
                              SizedBox(height: isMobile ? 20 : 24),
                              
                              Text(
                                'For the Best Experience',
                                style: TextStyle(
                                  fontSize: isMobile ? 20 : 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: isMobile ? 12 : 16),
                              
                              Text(
                                'Use headphones or earbuds to fully immerse yourself in our relaxing music collection.',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              SizedBox(height: isMobile ? 20 : 24),
                              
                              // Features list
                              Column(
                                children: [
                                  _buildFeatureItem(
                                    Icons.volume_up_rounded,
                                    'High-quality audio',
                                    isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  _buildFeatureItem(
                                    Icons.noise_control_off,
                                    'Noise isolation',
                                    isMobile,
                                  ),
                                  SizedBox(height: isMobile ? 12 : 16),
                                  _buildFeatureItem(
                                    Icons.spa,
                                    'Immersive relaxation',
                                    isMobile,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: isMobile ? 40 : 60),

                        // Action buttons
                        Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: isMobile ? 52 : 60,
                              child: ElevatedButton(
                                onPressed: _completeOnboarding,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: primaryColor.withOpacity(0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(isMobile ? 26 : 30),
                                  ),
                                ),
                                child: Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(height: isMobile ? 16 : 20),
                            
                            Text(
                              'Don\'t have headphones? No problem!\nYou can still enjoy our music.',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                color: Colors.grey.shade500,
                                height: 1.4,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text, bool isMobile) {
    return Row(
      children: [
        Container(
          width: isMobile ? 36 : 40,
          height: isMobile ? 36 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            icon,
            size: isMobile ? 18 : 20,
            color: primaryColor,
          ),
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: isMobile ? 14 : 16,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

