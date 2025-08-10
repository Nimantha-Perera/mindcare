import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';
import 'package:mindcare/presentation/pages/chatbot/happy_bot_page.dart';
import 'package:mindcare/presentation/pages/extrass_dash/extrass_dash.dart';
import 'package:mindcare/presentation/pages/mood_detector/mood_detecter.dart';
import 'package:mindcare/presentation/pages/relax_mind_dash/relax_my_mind_dash.dart';
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
  static const String settings1 = '/settings';  // Corrected: removed underscore
  static const String stressLevelQuiz = '/stress-level-quiz';
  static const String stressTipsPage = "/stress-tips-page";

  // Route generator function
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(
          builder: (_) => HomePage(),  // Added const
          settings: settings,
        );
      
      case happyBot:
        return MaterialPageRoute(
          builder: (_) => const HappyBotPage(),  // Added const
          settings: settings,
        );
      
      case extrasDash:
        return MaterialPageRoute(
          builder: (_) => const ExtrasDashboard(),  // Added const
          settings: settings,
        );
      
      case moodDetector:
        return MaterialPageRoute(
          builder: (_) => const FaceDetectionScreen(),  // Added const
          settings: settings,
        );
      
      case relaxMindDash:
        return MaterialPageRoute(
          builder: (_) => const RelaxMyMindDashboard(),  // Added const
          settings: settings,
        );
      
      case relaxMusics:
        return MaterialPageRoute(
          builder: (_) => const RelaxMusicsPage(),  // Added const
          settings: settings,
        );
      
      case settings1:  // Corrected: updated to match constant name
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),  // Added const
          settings: settings,
        );
      
      case stressLevelQuiz:
        return MaterialPageRoute(
          builder: (_) => const StressLevelQuiz(),  // Added const
          settings: settings,
        );
      case stressTipsPage:
        return MaterialPageRoute(
          builder: (_) => const StressTipsPage(),  // Added const
          settings: settings,
        );
      
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}