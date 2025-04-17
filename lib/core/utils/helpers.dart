import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // Format date to readable string
  static String formatDate(DateTime date) {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
  
  // Format time to readable string
  static String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }
  
  // Get greeting based on time of day
  static String getGreeting(String name) {
    final hour = DateTime.now().hour;
    
    if (hour < 12) {
      return 'Hello Good Morning, $name';
    } else if (hour < 17) {
      return 'Hello Good Afternoon, $name';
    } else {
      return 'Hello Good Evening, $name';
    }
  }
  
  // Show snackbar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }
  
  // Navigate to screen with slide animation
  static Future<dynamic> navigateWithSlideAnimation(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end).chain(
            CurveTween(curve: curve),
          );
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }
}