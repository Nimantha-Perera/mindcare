import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> _handleGoogleSignIn(BuildContext context) async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the login
      return;
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to home screen after successful login
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomePage()),
    );
  } catch (error) {
    print("Google Sign-In error: $error");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sign in failed. Please try again.')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              
              // Healthcare professionals illustration
              Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/icons/health.png',
                    width: 180,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Motivational text
              const Text(
                "Let's continue your journey toward\na calmer, healthier mind",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                ),
              ),
              
              const Spacer(flex: 1),
              
              // Google sign-in button
              ElevatedButton(
                onPressed: () => _handleGoogleSignIn(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 1,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/icons/google.png',
                      height: 24,
                      width: 24,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Login With',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Supportive message
              Column(
                children: const [
                  Text(
                    'Your thoughts are safe here.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "We're here to support, not to judge.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}