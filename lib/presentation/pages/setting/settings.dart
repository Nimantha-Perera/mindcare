import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/authentications/login.dart';
import 'package:mindcare/presentation/pages/setting/SettingItem.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  void _handleLogout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: user == null
            ? const Center(child: Text('No user info available.'))
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.teal.shade50,
                      Colors.white,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    // Custom header with back button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back_ios_new, color: Colors.teal),
                            ),
                          ),
                          const Expanded(
                            child: Center(
                              child: Text(
                                'Profile Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 40), // Balance the header
                        ],
                      ),
                    ),
                    
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            children: [
                              const SizedBox(height: 30),
                              
                              // Profile Picture with decorative border
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [Colors.teal.shade300, Colors.teal.shade700],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: user.photoURL != null
                                  ? CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white,
                                      backgroundImage: NetworkImage(user.photoURL!),
                                    )
                                  : const CircleAvatar(
                                      radius: 50,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person, size: 50, color: Colors.teal),
                                    ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // User Info Card
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      user.displayName ?? 'No Name',
                                      style: const TextStyle(
                                        fontSize: 22, 
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.email_outlined, size: 16, color: Colors.grey),
                                        const SizedBox(width: 6),
                                        Text(
                                          user.email ?? 'No Email',
                                          style: const TextStyle(
                                            color: Colors.grey, 
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 30),
                              
                              // Settings Options
                              SettingItem(
                                icon: Icons.notifications_outlined,
                                title: 'Notifications',
                                onTap: () {},
                              ),
                              
                              SettingItem(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Privacy',
                                onTap: () {},
                              ),
                              
                              SettingItem(
                                icon: Icons.security_outlined,
                                title: 'Security',
                                onTap: () {},
                              ),
                              
                              SettingItem(
                                icon: Icons.help_outline,
                                title: 'Help & Support',
                                onTap: () {},
                              ),
                              
                              const SizedBox(height: 40),
                              
                              // Logout Button
                              ElevatedButton.icon(
                                onPressed: () => _handleLogout(context),
                                icon: const Icon(Icons.logout, color: Colors.white),
                                label: const Text(
                                  'Logout',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  minimumSize: const Size(double.infinity, 55),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                              
                              const SizedBox(height: 30),
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
}