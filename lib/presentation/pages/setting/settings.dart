import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mindcare/presentation/pages/authentications/login.dart';
import 'package:mindcare/presentation/pages/setting/edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _handleLogout(BuildContext context) async {
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Logout'),
            content: const Text('Are you sure you want to sign out of your account?'),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseAuth.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Account Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: user == null
          ? const Center(
              child: Text(
                'User information unavailable',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header Section
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user.photoURL != null
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: user.photoURL == null
                                  ? Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    )
                                  : null,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: _navigateToEditProfile,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[600],
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2),
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.displayName ?? 'User Name',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email ?? 'user@email.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _navigateToEditProfile,
                            icon: const Icon(Icons.edit_outlined),
                            label: const Text('Edit Profile'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.blue[600]!),
                              foregroundColor: Colors.blue[600],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Account Section
                  _buildSectionHeader('Account'),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.security_outlined,
                          title: 'Security',
                          subtitle: 'Password and authentication',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy',
                          subtitle: 'Data and privacy controls',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.notifications_outlined,
                          title: 'Notifications',
                          subtitle: 'Manage your notifications',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Support Section
                  _buildSectionHeader('Support'),
                  Container(
                    color: Colors.white,
                    child: Column(
                      children: [
                        _buildSettingItem(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'FAQs and support articles',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.contact_support_outlined,
                          title: 'Contact Us',
                          subtitle: 'Get in touch with support',
                          onTap: () {},
                        ),
                        _buildDivider(),
                        _buildSettingItem(
                          icon: Icons.info_outline,
                          title: 'About',
                          subtitle: 'App version and information',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sign Out Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _handleLogout(context),
                        icon: const Icon(Icons.logout),
                        label: const Text(
                          'Sign Out',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.grey[600],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.grey[700], size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Colors.grey[200],
    );
  }
}