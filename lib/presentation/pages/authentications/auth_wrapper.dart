import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/authentications/login.dart';
import 'package:mindcare/presentation/pages/home/home_page.dart';
import 'package:mindcare/presentation/pages/admins/admin_dash.dart';
import 'package:mindcare/presentation/pages/authentications/service/authfirestore.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // User is not logged in
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // User is logged in - check role and navigate accordingly
        return FutureBuilder<String?>(
          future: _getUserRole(snapshot.data!.uid),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Setting up your account...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // Navigate based on user role
            final userRole = roleSnapshot.data;
            if (userRole == 'admin') {
              return AdminDashboard();
            } else {
              return HomePage();
            }
          },
        );
      },
    );
  }

  Future<String?> _getUserRole(String uid) async {
    try {
      final UserService userService = UserService();
      return await userService.getUserRole(uid);
    } catch (e) {
      print('Error getting user role: $e');
      return null; // Default to regular user if role fetch fails
    }
  }
}