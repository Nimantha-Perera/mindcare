import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindcare/presentation/pages/admins/screens/appoiments_menagment.dart';
import 'package:mindcare/presentation/pages/admins/screens/relax_music_upload.dart';
import 'package:mindcare/presentation/pages/admins/screens/therapist_management_screen.dart';
import 'package:mindcare/presentation/pages/admins/screens/user_manegment.dart';
import 'package:mindcare/presentation/pages/authentications/login.dart';
import 'package:mindcare/presentation/pages/authentications/service/authfirestore.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final UserService _userService = UserService();
  String _adminName = '';
  bool _isLoading = true;
  int _selectedIndex = 0;

  int _userCount = 0;
  int _doctorCount = 0;
  int _musicCount = 0; // Added music count

  final List<Widget> _screens = const [
    Placeholder(), 
    UserManagementScreen(),
    TherapistManagementScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAdminData();
    _loadCounts();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final adminData = await _userService.getCurrentUserData();
      if (adminData != null) {
        setState(() => _adminName = adminData['name'] ?? 'Admin');
      }
    } catch (e) {
      print('Error loading admin data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadCounts() async {
    try {
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final doctorsSnap = await FirebaseFirestore.instance.collection('doctors').get();
      
      // Load music count from Firebase Storage (you might need to adjust this based on your storage structure)
      // For now, we'll set it to 0 and update it when needed
      setState(() {
        _userCount = usersSnap.docs.length;
        _doctorCount = doctorsSnap.docs.length;
        _musicCount = 0; // You can implement actual music count later
      });
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTablet = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(isDesktop ? 24 : 16),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isDesktop ? 1200 : double.infinity),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(isTablet),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildCounts(isTablet, isDesktop),
                  SizedBox(height: isTablet ? 32 : 24),
                  _buildQuickActions(isTablet, isDesktop),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(bool isTablet) {
    return Card(
      elevation: 0, 
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300), 
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isTablet ? 32 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_adminName!',
              style: TextStyle(
                fontSize: isTablet ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            if (isTablet) ...[
              const SizedBox(height: 8),
              Text(
                'Manage your MindCare platform from here',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCounts(bool isTablet, bool isDesktop) {
    final cardSpacing = isDesktop ? 24.0 : 16.0;
    
    return isTablet
        ? Row(
            children: [
              Expanded(
                child: _buildStatsCard(
                  'Total Users', 
                  _userCount, 
                  Icons.group, 
                  Colors.indigo,
                  isTablet,
                ),
              ),
              SizedBox(width: cardSpacing),
              Expanded(
                child: _buildStatsCard(
                  'Total Therapists', 
                  _doctorCount, 
                  Icons.psychology, 
                  Colors.green,
                  isTablet,
                ),
              ),
              SizedBox(width: cardSpacing),
              Expanded(
                child: _buildStatsCard(
                  'Relax Music', 
                  _musicCount, 
                  Icons.music_note, 
                  Colors.purple,
                  isTablet,
                ),
              ),
            ],
          )
        : Column(
            children: [
              _buildStatsCard(
                'Total Users', 
                _userCount, 
                Icons.group, 
                Colors.indigo,
                isTablet,
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                'Total Therapists', 
                _doctorCount, 
                Icons.psychology, 
                Colors.green,
                isTablet,
              ),
              const SizedBox(height: 16),
              _buildStatsCard(
                'Relax Music', 
                _musicCount, 
                Icons.music_note, 
                Colors.purple,
                isTablet,
              ),
            ],
          );
  }

  Widget _buildStatsCard(String title, int value, IconData icon, Color color, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(isTablet ? 24 : 16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isTablet ? 16 : 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: isTablet ? 40 : 32, color: color),
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontSize: isTablet ? 32 : 24, 
                      fontWeight: FontWeight.bold, 
                      color: color,
                    ),
                  ),
                  Text(
                    title, 
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isTablet ? 16 : 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(bool isTablet, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isTablet ? 24 : 18, 
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? 20 : 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = isDesktop ? 4 : (isTablet ? 3 : 2);
            final aspectRatio = isDesktop ? 1.3 : (isTablet ? 1.2 : 1.1);
            
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: isTablet ? 20 : 16,
              mainAxisSpacing: isTablet ? 20 : 16,
              childAspectRatio: aspectRatio,
              children: [
                _buildActionCard(
                  'Manage Users',
                  Icons.group,
                  Colors.indigo,
                  () => _navigateTo(const UserManagementScreen()),
                  isTablet,
                ),
                _buildActionCard(
                  'Manage Therapists',
                  Icons.psychology,
                  Colors.green,
                  () => _navigateTo(const TherapistManagementScreen()),
                  isTablet,
                ),
                _buildActionCard(
                  'Upload Music',
                  Icons.music_note,
                  Colors.purple,
                  () => _navigateTo(const RelaxMusicUploadScreen()),
                  isTablet,
                ),
                _buildActionCard(
                  'Appoiments',
                  Icons.note,
                  Colors.purple,
                  () => _navigateTo(const AdminManageAppointments()),
                  isTablet,
                ),
                if (isTablet) ...[
                  _buildActionCard(
                    'Reports',
                    Icons.analytics,
                    Colors.orange,
                    () => {}, // Add navigation
                    isTablet,
                  ),
                  if (isDesktop)
                    _buildActionCard(
                      'Settings',
                      Icons.settings,
                      Colors.grey,
                      () => {}, // Add navigation
                      isTablet,
                    ),
                ],
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, bool isTablet) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isTablet ? 20 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 16 : 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: isTablet ? 48 : 40, color: color),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w600, 
                  fontSize: isTablet ? 16 : 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(Widget screen) {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => screen)
    ).then((_) {
      // Refresh counts when returning from music upload screen
      _loadCounts();
    });
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
               Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => LoginScreen()),
            );
              },
              child: const Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 900;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Admin Dashboard',
          style: TextStyle(fontSize: isDesktop ? 24 : 20),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (isDesktop) ...[
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
          ],
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedIndex == 0
              ? _buildDashboard()
              : _screens[_selectedIndex],
      bottomNavigationBar: isDesktop
          ? null
          : BottomNavigationBar(
              type: BottomNavigationBarType.fixed, // Add this to show all items
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.teal,
              unselectedItemColor: Colors.grey,
              onTap: _onItemTapped,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Users',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.psychology),
                  label: 'Therapists',
                ),
              ],
            ),
      drawer: isDesktop
          ? null
          : Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: const BoxDecoration(color: Colors.teal),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.admin_panel_settings, size: 35, color: Colors.teal),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _adminName,
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.dashboard),
                    title: const Text('Dashboard'),
                    selected: _selectedIndex == 0,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(0);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Users'),
                    selected: _selectedIndex == 1,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(1);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.psychology),
                    title: const Text('Therapists'),
                    selected: _selectedIndex == 2,
                    onTap: () {
                      Navigator.pop(context);
                      _onItemTapped(2);
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.music_note, color: Colors.purple),
                    title: const Text('Upload Music'),
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo(const RelaxMusicUploadScreen());
                    },
                  ),
                ],
              ),
            ),
      floatingActionButton: isDesktop 
          ? FloatingActionButton.extended(
              onPressed: () => _navigateTo(const RelaxMusicUploadScreen()),
              backgroundColor: Colors.purple,
              icon: const Icon(Icons.music_note),
              label: const Text('Upload Music'),
            )
          : null,
    );
  }
}