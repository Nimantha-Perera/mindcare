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
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? false;
    
    final bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(isAnonymous ? 'End Anonymous Session' : 'Confirm Logout'),
            content: Text(isAnonymous 
                ? 'Are you sure you want to end your anonymous session? Your data will be lost if not backed up.'
                : 'Are you sure you want to sign out of your account?'),
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
                child: Text(isAnonymous ? 'End Session' : 'Sign Out'),
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
    final User? user = FirebaseAuth.instance.currentUser;
    
    // Check if user is anonymous
    if (user?.isAnonymous == true) {
      _showAnonymousUserDialog();
      return;
    }

    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfileScreen(),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void _showAnonymousUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Anonymous User'),
        content: const Text(
          'To edit your profile, you need to create an account or sign in with Google. Would you like to do that now?'
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout(context); // This will take them to login screen
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  void _showAnonymousLimitationDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Unavailable'),
        content: Text(
          'This $feature feature requires a registered account. Create an account or sign in with Google to access this feature.'
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _handleLogout(context);
            },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  String _getUserDisplayName(User? user) {
    if (user == null) return 'Unknown User';
    if (user.isAnonymous) return 'Anonymous User';
    return user.displayName ?? 'User Name';
  }

  String _getUserEmail(User? user) {
    if (user == null) return 'No email';
    if (user.isAnonymous) return 'No email (anonymous)';
    return user.email ?? 'No email';
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final bool isAnonymous = user?.isAnonymous ?? false;

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
                              backgroundColor: isAnonymous ? Colors.grey[300] : Colors.grey[200],
                              backgroundImage: (!isAnonymous && user.photoURL != null)
                                  ? NetworkImage(user.photoURL!)
                                  : null,
                              child: Icon(
                                isAnonymous ? Icons.person_outline : Icons.person,
                                size: 50,
                                color: isAnonymous ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                            if (!isAnonymous)
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
                          _getUserDisplayName(user),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getUserEmail(user),
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        

                        
                        const SizedBox(height: 20),
                        if (!isAnonymous)
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
                          subtitle: isAnonymous 
                              ? 'Requires account registration'
                              : 'Password and authentication',
                          onTap: isAnonymous 
                              ? () => _showAnonymousLimitationDialog('security')
                              : () {},
                          isDisabled: isAnonymous,
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
                          subtitle: isAnonymous 
                              ? 'Limited for anonymous users'
                              : 'Manage your notifications',
                          onTap: isAnonymous 
                              ? () => _showAnonymousLimitationDialog('notification')
                              : () {},
                          isDisabled: isAnonymous,
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
                        icon: Icon(isAnonymous ? Icons.exit_to_app : Icons.logout),
                        label: Text(
                          isAnonymous ? 'End Session' : 'Sign Out',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
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
    bool isDisabled = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon, 
          color: isDisabled ? Colors.grey[400] : Colors.grey[700], 
          size: 24
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: isDisabled ? Colors.grey[400] : Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: isDisabled ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: isDisabled ? Colors.grey[300] : Colors.grey[400],
      ),
      onTap: onTap,
      enabled: !isDisabled,
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