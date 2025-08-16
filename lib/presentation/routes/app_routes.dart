import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';
import 'package:mindcare/presentation/pages/chatbot/happy_bot_page.dart';
import 'package:mindcare/presentation/pages/extrass_dash/extrass_dash.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_mind_dash/relax_my_mind_dash.dart';
import 'package:mindcare/presentation/pages/relax_musics/onboard_screen.dart';
import 'package:mindcare/presentation/pages/relax_musics/relax_musics_page.dart';
import 'package:mindcare/presentation/pages/setting/settings.dart';
import 'package:mindcare/presentation/pages/stress_level/screens/stress_level_quiz.dart';
import 'package:mindcare/presentation/pages/tips/stress_tips_page.dart';

class AppRoutes {
  // Route names as constants
  static const String home = '/home';
  static const String happyBot = '/happy-bot';
  static const String extrasDash = '/extras-dash';
  static const String moodDetector = '/mood-detector';
  static const String relaxMindDash = '/relax-mind-dash';
  static const String relaxMusics = '/relax-musics';
  static const String relaxMusicsPage = '/relax-musics-page'; 
  static const String settings1 = '/settings';
  static const String stressLevelQuiz = '/stress-level-quiz';
  static const String stressTipsPage = "/stress-tips-page";

  // Route generator function
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final routeName = settings.name;
    
    switch (routeName) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomePage(),
          settings: settings,
        );
      
      case happyBot:
        return MaterialPageRoute(
          builder: (_) => const HappyBotPage(),
          settings: settings,
        );
      
      case extrasDash:
        return MaterialPageRoute(
          builder: (_) => const ExtrasDashboard(),
          settings: settings,
        );
      
      case moodDetector:
        return MaterialPageRoute(
          builder: (_) => const FaceDetectionScreen(),
          settings: settings,
        );
      
      case relaxMindDash:
        return MaterialPageRoute(
          builder: (_) => const RelaxMyMindDashboard(),
          settings: settings,
        );
      
      case relaxMusics:
        // Always show onboarding before going to relax music
        return MaterialPageRoute(
          builder: (_) => const OnboardingScreen(),
          settings: settings,
        );
      
      case relaxMusicsPage:
        return MaterialPageRoute(
          builder: (_) => const RelaxMusicsPage(),
          settings: settings,
        );
      
      case settings1:
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
          settings: settings,
        );
      
      case stressLevelQuiz:
        return MaterialPageRoute(
          builder: (_) => const StressLevelQuiz(),
          settings: settings,
        );
      
      case stressTipsPage:
        return MaterialPageRoute(
          builder: (_) => const StressTipsPage(),
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeName ?? "unknown route"}'),
            ),
          ),
        );
    }
  }
}