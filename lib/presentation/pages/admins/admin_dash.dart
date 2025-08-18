import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Add this import
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
  int _musicCount = 0;

  final List<Widget> _screens = const [
    Placeholder(), 
    UserManagementScreen(),
    TherapistManagementScreen(),
  ];

  // Responsive breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

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
      // Load users and doctors count
      final usersSnap = await FirebaseFirestore.instance.collection('users').get();
      final doctorsSnap = await FirebaseFirestore.instance.collection('doctors').get();
      
      // Load music count from Firebase Storage
      int musicCount = 0;
      try {
        final ListResult musicResult = await FirebaseStorage.instance.ref('musics').listAll();
        musicCount = musicResult.items.length;
      } catch (e) {
        print('Error loading music count: $e');
        // Keep musicCount as 0 if there's an error
      }
      
      if (mounted) {
        setState(() {
          _userCount = usersSnap.docs.length;
          _doctorCount = doctorsSnap.docs.length;
          _musicCount = musicCount;
        });
      }
    } catch (e) {
      print('Error fetching counts: $e');
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Helper methods to determine device type
  bool isMobile(double width) => width < mobileBreakpoint;
  bool isTablet(double width) => width >= mobileBreakpoint && width < tabletBreakpoint;
  bool isDesktop(double width) => width >= tabletBreakpoint;
  bool isLargeDesktop(double width) => width >= desktopBreakpoint;

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobileDevice = isMobile(screenWidth);
        final isTabletDevice = isTablet(screenWidth);
        final isDesktopDevice = isDesktop(screenWidth);
        final isLargeDesktopDevice = isLargeDesktop(screenWidth);
        
        // Responsive padding
        final horizontalPadding = isMobileDevice ? 16.0 : 
                                 isTabletDevice ? 20.0 : 
                                 isLargeDesktopDevice ? 32.0 : 24.0;
        
        final verticalPadding = isMobileDevice ? 16.0 : 
                               isTabletDevice ? 20.0 : 24.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: isLargeDesktopDevice ? 1400 : 
                         isDesktopDevice ? 1200 : double.infinity,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeSection(screenWidth),
                  SizedBox(height: isMobileDevice ? 20 : isTabletDevice ? 28 : 32),
                  _buildStatsSection(screenWidth),
                  SizedBox(height: isMobileDevice ? 20 : isTabletDevice ? 28 : 32),
                  _buildQuickActions(screenWidth),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeSection(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    final isDesktopDevice = isDesktop(screenWidth);

    return Card(
      elevation: isMobileDevice ? 1 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(
          isMobileDevice ? 16 : 
          isTabletDevice ? 24 : 32,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $_adminName!',
              style: TextStyle(
                fontSize: isMobileDevice ? 20 : 
                         isTabletDevice ? 24 : 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (!isMobileDevice) ...[
              SizedBox(height: isDesktopDevice ? 12 : 8),
              Text(
                'Manage your MindCare platform from here',
                style: TextStyle(
                  fontSize: isTabletDevice ? 14 : 16,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    final isDesktopDevice = isDesktop(screenWidth);
    
    // Responsive grid configuration
    final crossAxisCount = isMobileDevice ? 1 : 
                           isTabletDevice ? 2 : 3;
    
    final childAspectRatio = isMobileDevice ? 3.5 : 
                            isTabletDevice ? 2.8 : 2.2;
    
    final cardSpacing = isMobileDevice ? 12.0 : 
                        isTabletDevice ? 16.0 : 20.0;

    // Stats data
    final statsData = [
      {
        'title': 'Total Users',
        'value': _userCount,
        'icon': Icons.group,
        'color': Colors.indigo,
      },
      {
        'title': 'Total Therapists',
        'value': _doctorCount,
        'icon': Icons.psychology,
        'color': Colors.green,
      },
      {
        'title': 'Relax Music',
        'value': _musicCount,
        'icon': Icons.music_note,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: cardSpacing,
        mainAxisSpacing: cardSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: statsData.length,
      itemBuilder: (context, index) {
        final stat = statsData[index];
        return _buildStatsCard(
          stat['title'] as String,
          stat['value'] as int,
          stat['icon'] as IconData,
          stat['color'] as Color,
          screenWidth,
        );
      },
    );
  }

  Widget _buildStatsCard(String title, int value, IconData icon, Color color, double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    
    return Card(
      elevation: isMobileDevice ? 2 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobileDevice ? 12 : isTabletDevice ? 16 : 20),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobileDevice ? 8 : isTabletDevice ? 12 : 16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
              ),
              child: Icon(
                icon, 
                size: isMobileDevice ? 24 : isTabletDevice ? 32 : 40, 
                color: color,
              ),
            ),
            SizedBox(width: isMobileDevice ? 12 : isTabletDevice ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '$value',
                      style: TextStyle(
                        fontSize: isMobileDevice ? 20 : isTabletDevice ? 28 : 32, 
                        fontWeight: FontWeight.bold, 
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      title, 
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: isMobileDevice ? 12 : isTabletDevice ? 14 : 16,
                        fontWeight: FontWeight.w500,
                      ),
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

  Widget _buildQuickActions(double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);
    final isDesktopDevice = isDesktop(screenWidth);
    final isLargeDesktopDevice = isLargeDesktop(screenWidth);

    // Action items data
    final actionItems = [
      {
        'title': 'Manage Therapists',
        'icon': Icons.psychology,
        'color': Colors.green,
        'onTap': () => _navigateTo(const TherapistManagementScreen()),
      },
      {
        'title': 'Manage Users',
        'icon': Icons.group,
        'color': Colors.indigo,
        'onTap': () => _navigateTo(const UserManagementScreen()),
      },
      {
        'title': 'Appointments',
        'icon': Icons.event_note,
        'color': Colors.orange,
        'onTap': () => _navigateTo(const AdminManageAppointments()),
      },
      
      {
        'title': 'Upload Music',
        'icon': Icons.music_note,
        'color': Colors.purple,
        'onTap': () => _navigateTo(const RelaxMusicUploadScreen()),
      },
      
      if (!isMobileDevice) ...[
        {
          'title': 'Reports',
          'icon': Icons.analytics,
          'color': Colors.teal,
          'onTap': () => {}, // Add navigation
        },
        if (isDesktopDevice)
          {
            'title': 'Settings',
            'icon': Icons.settings,
            'color': Colors.blueGrey,
            'onTap': () => {}, // Add navigation
          },
      ],
    ];

    // Responsive grid configuration
    final crossAxisCount = isMobileDevice ? 2 : 
                           isTabletDevice ? 3 : 
                           isLargeDesktopDevice ? 4 : 3;
    
    final aspectRatio = isMobileDevice ? 1.0 : 
                        isTabletDevice ? 1.1 : 1.2;
    
    final cardSpacing = isMobileDevice ? 12.0 : 
                        isTabletDevice ? 16.0 : 20.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: isMobileDevice ? 18 : isTabletDevice ? 20 : 24, 
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: isMobileDevice ? 12 : isTabletDevice ? 16 : 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: cardSpacing,
            mainAxisSpacing: cardSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemCount: actionItems.length,
          itemBuilder: (context, index) {
            final action = actionItems[index];
            return _buildActionCard(
              action['title'] as String,
              action['icon'] as IconData,
              action['color'] as Color,
              action['onTap'] as VoidCallback,
              screenWidth,
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap, double screenWidth) {
    final isMobileDevice = isMobile(screenWidth);
    final isTabletDevice = isTablet(screenWidth);

    return Card(
      elevation: isMobileDevice ? 2 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
        child: Padding(
          padding: EdgeInsets.all(isMobileDevice ? 12 : isTabletDevice ? 16 : 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isMobileDevice ? 10 : isTabletDevice ? 14 : 16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(isMobileDevice ? 8 : 12),
                ),
                child: Icon(
                  icon, 
                  size: isMobileDevice ? 28 : isTabletDevice ? 36 : 44, 
                  color: color,
                ),
              ),
              SizedBox(height: isMobileDevice ? 8 : isTabletDevice ? 12 : 16),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600, 
                    fontSize: isMobileDevice ? 12 : isTabletDevice ? 14 : 16,
                    color: Colors.black87,
                  ),
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
      // Refresh counts when returning from any screen
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

  Widget _buildResponsiveNavigationRail(double screenWidth) {
    if (!isDesktop(screenWidth)) return const SizedBox.shrink();
    
    return NavigationRail(
      selectedIndex: _selectedIndex,
      onDestinationSelected: _onItemTapped,
      backgroundColor: Colors.grey.shade50,
      selectedIconTheme: const IconThemeData(color: Colors.teal, size: 28),
      unselectedIconTheme: IconThemeData(color: Colors.grey.shade600, size: 24),
      selectedLabelTextStyle: const TextStyle(color: Colors.teal, fontWeight: FontWeight.w600),
      unselectedLabelTextStyle: TextStyle(color: Colors.grey.shade600),
      minWidth: 80,
      labelType: NavigationRailLabelType.selected,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.group_outlined),
          selectedIcon: Icon(Icons.group),
          label: Text('Users'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.psychology_outlined),
          selectedIcon: Icon(Icons.psychology),
          label: Text('Therapists'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isMobileDevice = isMobile(screenWidth);
        final isDesktopDevice = isDesktop(screenWidth);

        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Admin Dashboard',
              style: TextStyle(
                fontSize: isMobileDevice ? 18 : isDesktopDevice ? 24 : 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            elevation: isMobileDevice ? 2 : 0,
            centerTitle: isMobileDevice,
            actions: [
              if (isDesktopDevice) ...[
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () {},
                  tooltip: 'Notifications',
                ),
                const SizedBox(width: 8),
              ],
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadCounts,
                tooltip: 'Refresh Data',
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
                tooltip: 'Logout',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator(color: Colors.teal))
              : Row(
                  children: [
                    _buildResponsiveNavigationRail(screenWidth),
                    Expanded(
                      child: _selectedIndex == 0
                          ? _buildDashboard()
                          : _screens[_selectedIndex],
                    ),
                  ],
                ),
          bottomNavigationBar: !isDesktopDevice
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  currentIndex: _selectedIndex,
                  selectedItemColor: Colors.teal,
                  unselectedItemColor: Colors.grey,
                  onTap: _onItemTapped,
                  elevation: 8,
                  selectedFontSize: isMobileDevice ? 12 : 14,
                  unselectedFontSize: isMobileDevice ? 10 : 12,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.dashboard_outlined),
                      activeIcon: Icon(Icons.dashboard),
                      label: 'Dashboard',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.group_outlined),
                      activeIcon: Icon(Icons.group),
                      label: 'Users',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.psychology_outlined),
                      activeIcon: Icon(Icons.psychology),
                      label: 'Therapists',
                    ),
                  ],
                )
              : null,
          drawer: isMobileDevice
              ? Drawer(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DrawerHeader(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.teal],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            const CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.white,
                              child: Icon(Icons.admin_panel_settings, size: 30, color: Colors.teal),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _adminName,
                              style: const TextStyle(
                                color: Colors.white, 
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Administrator',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8), 
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildDrawerItem(Icons.dashboard, 'Dashboard', 0),
                      _buildDrawerItem(Icons.group, 'Users', 1),
                      _buildDrawerItem(Icons.psychology, 'Therapists', 2),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.music_note, color: Colors.purple),
                        title: const Text('Upload Music'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateTo(const RelaxMusicUploadScreen());
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.event_note, color: Colors.orange),
                        title: const Text('Appointments'),
                        onTap: () {
                          Navigator.pop(context);
                          _navigateTo(const AdminManageAppointments());
                        },
                      ),
                    ],
                  ),
                )
              : null,
          floatingActionButton: isDesktopDevice 
              ? FloatingActionButton.extended(
                  onPressed: () => _navigateTo(const RelaxMusicUploadScreen()),
                  backgroundColor: Colors.purple,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.music_note),
                  label: const Text('Upload Music'),
                  elevation: 4,
                )
              : null,
        );
      },
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon, color: _selectedIndex == index ? Colors.teal : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          color: _selectedIndex == index ? Colors.teal : Colors.black87,
          fontWeight: _selectedIndex == index ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
      selected: _selectedIndex == index,
      selectedTileColor: Colors.teal.withOpacity(0.1),
      onTap: () {
        Navigator.pop(context);
        _onItemTapped(index);
      },
    );
  }
}