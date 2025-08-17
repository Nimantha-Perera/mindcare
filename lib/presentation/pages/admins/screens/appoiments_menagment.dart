import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/data/datasources/appiment_datasource.dart';
import 'package:mindcare/data/models/appoiment_modal.dart';
import 'package:mindcare/presentation/pages/admins/widgets/appoiment_card.dart';
import 'package:mindcare/presentation/pages/admins/widgets/filter_dialog.dart';
import 'package:mindcare/presentation/pages/admins/widgets/static_widget.dart';



class AdminManageAppointments extends StatefulWidget {
  const AdminManageAppointments({Key? key}) : super(key: key);

  @override
  State<AdminManageAppointments> createState() => _AdminManageAppointmentsState();
}

class _AdminManageAppointmentsState extends State<AdminManageAppointments>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Filter variables
  String _selectedStatusFilter = 'all';
  String _selectedDoctorFilter = 'all';
  DateTime? _selectedDateFilter;
  bool _emergencyOnlyFilter = false;
  String _searchQuery = '';
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  
  // Statistics
  Map<String, int> _appointmentStats = {};
  double _totalRevenue = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadStatistics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadStatistics() async {
    final statsData = await AppointmentService.getAppointmentStatistics();
    setState(() {
      _appointmentStats = statsData['stats'];
      _totalRevenue = statsData['revenue'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final isTablet = screenWidth >= 600 && screenWidth < 1200;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Manage Appointments',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6A4C93),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            onPressed: _exportAppointments,
            icon: const Icon(Icons.download),
          ),
        ],
        bottom: isMobile ? null : TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          isScrollable: isTablet,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
            Tab(icon: Icon(Icons.schedule), text: 'Upcoming'),
            Tab(icon: Icon(Icons.pending), text: 'Pending'),
            Tab(icon: Icon(Icons.check_circle), text: 'Completed'),
            Tab(icon: Icon(Icons.cancel), text: 'Cancelled'),
          ],
        ),
      ),
      drawer: isMobile ? _buildMobileDrawer() : null,
      body: Column(
        children: [
          _buildSearchAndStats(),
          Expanded(
            child: isMobile 
              ? _buildMobileView()
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildAppointmentListTab('upcoming'),
                    _buildAppointmentListTab('pending'),
                    _buildAppointmentListTab('completed'),
                    _buildAppointmentListTab('cancelled'),
                  ],
                ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _showCreateAppointmentDialog,
      //   backgroundColor: const Color(0xFF6A4C93),
      //   icon: const Icon(Icons.add),
      //   label: const Text('New Appointment'),
      // ),
    );
  }

  Widget _buildMobileDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(0xFF6A4C93),
            ),
            child: Text(
              'Appointment Filters',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          _buildDrawerItem(Icons.dashboard, 'Overview', 0),
          _buildDrawerItem(Icons.schedule, 'Upcoming', 1),
          _buildDrawerItem(Icons.pending, 'Pending', 2),
          _buildDrawerItem(Icons.check_circle, 'Completed', 3),
          _buildDrawerItem(Icons.cancel, 'Cancelled', 4),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String title, int tabIndex) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        _tabController.animateTo(tabIndex);
      },
    );
  }

  Widget _buildMobileView() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildOverviewTab(),
        _buildAppointmentListTab('upcoming'),
        _buildAppointmentListTab('pending'),
        _buildAppointmentListTab('completed'),
        _buildAppointmentListTab('cancelled'),
      ],
    );
  }

  Widget _buildSearchAndStats() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by patient name, doctor, or ID...',
              prefixIcon: const Icon(Icons.search, color: Color(0xFF6A4C93)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF6A4C93), width: 2),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Quick Stats
          QuickStatsRow(
            appointmentStats: _appointmentStats,
            totalRevenue: _totalRevenue,
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Appointment Analytics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A4C93),
            ),
          ),
          const SizedBox(height: 20),
          
          // Detailed Stats Cards
          DetailedStatsGrid(appointmentStats: _appointmentStats),
          const SizedBox(height: 24),
          
          // Recent Activity
          const Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const RecentActivityList(),
        ],
      ),
    );
  }

  Widget _buildAppointmentListTab(String status) {
    return StreamBuilder<QuerySnapshot>(
      stream: AppointmentService.getAppointmentsStream(status: status),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6A4C93)),
          );
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final appointments = snapshot.data?.docs
                .map((doc) => Appointment.fromFirestore(doc))
                .where(_filterAppointment)
                .toList() ??
            [];

        if (appointments.isEmpty) {
          return _buildEmptyState(status);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: appointments.length,
          itemBuilder: (context, index) {
            return AppointmentCard(
              appointment: appointments[index],
              onStatusChanged: _loadStatistics,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text('Error loading appointments: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => setState(() {}),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String status) {
    String title;
    String subtitle;
    IconData icon;

    switch (status) {
      case 'pending':
        title = 'No Pending Appointments';
        subtitle = 'All appointments have been processed';
        icon = Icons.pending_actions;
        break;
      case 'upcoming':
        title = 'No Upcoming Appointments';
        subtitle = 'No confirmed appointments scheduled';
        icon = Icons.schedule;
        break;
      case 'completed':
        title = 'No Completed Appointments';
        subtitle = 'Completed appointments will appear here';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        title = 'No Cancelled Appointments';
        subtitle = 'Cancelled appointments will appear here';
        icon = Icons.cancel_outlined;
        break;
      default:
        title = 'No Appointments';
        subtitle = 'No appointments found';
        icon = Icons.event_note;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  bool _filterAppointment(Appointment appointment) {
    // Search filter
    if (_searchQuery.isNotEmpty) {
      final searchLower = _searchQuery.toLowerCase();
      if (!appointment.patientName.toLowerCase().contains(searchLower) &&
          !appointment.doctorName.toLowerCase().contains(searchLower) &&
          !appointment.id.toLowerCase().contains(searchLower)) {
        return false;
      }
    }

    // Doctor filter
    if (_selectedDoctorFilter != 'all' && 
        appointment.doctorName != _selectedDoctorFilter) {
      return false;
    }

    // Date filter
    if (_selectedDateFilter != null) {
      final appointmentDate = DateTime(
        appointment.appointmentDate.year,
        appointment.appointmentDate.month,
        appointment.appointmentDate.day,
      );
      final filterDate = DateTime(
        _selectedDateFilter!.year,
        _selectedDateFilter!.month,
        _selectedDateFilter!.day,
      );
      if (!appointmentDate.isAtSameMomentAs(filterDate)) {
        return false;
      }
    }

    // Emergency filter
    if (_emergencyOnlyFilter && !appointment.isEmergency) {
      return false;
    }

    return true;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => FilterDialog(
        selectedStatusFilter: _selectedStatusFilter,
        selectedDoctorFilter: _selectedDoctorFilter,
        selectedDateFilter: _selectedDateFilter,
        emergencyOnlyFilter: _emergencyOnlyFilter,
        onFiltersChanged: (statusFilter, doctorFilter, dateFilter, emergencyFilter) {
          setState(() {
            _selectedStatusFilter = statusFilter;
            _selectedDoctorFilter = doctorFilter;
            _selectedDateFilter = dateFilter;
            _emergencyOnlyFilter = emergencyFilter;
          });
        },
      ),
    );
  }

  void _showCreateAppointmentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Create appointment functionality coming soon!'),
        backgroundColor: Color(0xFF6A4C93),
      ),
    );
  }

  void _exportAppointments() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        backgroundColor: Color(0xFF6A4C93),
      ),
    );
  }
}