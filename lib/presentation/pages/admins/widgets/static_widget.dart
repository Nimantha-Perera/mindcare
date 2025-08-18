import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/data/datasources/appiment_datasource.dart';
import 'package:mindcare/data/models/appoiment_modal.dart';

// Responsive breakpoints helper
class ResponsiveHelper {
  static bool isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  static bool isTablet(BuildContext context) => MediaQuery.of(context).size.width >= 600 && MediaQuery.of(context).size.width < 1024;
  static bool isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;
  
  static int getGridColumns(BuildContext context) {
    if (isMobile(context)) return 1;
    if (isTablet(context)) return 2;
    return 4;
  }
  
  static double getCardPadding(BuildContext context) {
    if (isMobile(context)) return 8.0;
    if (isTablet(context)) return 12.0;
    return 16.0;
  }
}

class QuickStatsRow extends StatelessWidget {
  final Map<String, int> appointmentStats;
  final double totalRevenue;

  const QuickStatsRow({
    Key? key,
    required this.appointmentStats,
    required this.totalRevenue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    
    if (isMobile) {
      // Stack cards vertically on mobile for better readability
      return Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Total',
                  value: '${appointmentStats.values.fold(0, (sum, count) => sum + count)}',
                  icon: Icons.event_note,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  title: 'Pending',
                  value: '${appointmentStats['pending'] ?? 0}',
                  icon: Icons.pending,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  title: 'Completed',
                  value: '${appointmentStats['completed'] ?? 0}',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: StatCard(
                  title: 'Revenue',
                  value: 'LKR ${AppointmentService.formatCurrency(totalRevenue.toInt())}',
                  icon: Icons.monetization_on,
                  color: const Color(0xFF6A4C93),
                ),
              ),
            ],
          ),
        ],
      );
    }

    // Horizontal layout for tablet and desktop
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Total',
            value: '${appointmentStats.values.fold(0, (sum, count) => sum + count)}',
            icon: Icons.event_note,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Pending',
            value: '${appointmentStats['pending'] ?? 0}',
            icon: Icons.pending,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Completed',
            value: '${appointmentStats['completed'] ?? 0}',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            title: 'Revenue',
            value: 'LKR ${AppointmentService.formatCurrency(totalRevenue.toInt())}',
            icon: Icons.monetization_on,
            color: const Color(0xFF6A4C93),
          ),
        ),
      ],
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final padding = ResponsiveHelper.getCardPadding(context);
    
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: isMobile ? 18 : 20,
          ),
          SizedBox(height: isMobile ? 2 : 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: isMobile ? 12 : 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class DetailedStatsGrid extends StatelessWidget {
  final Map<String, int> appointmentStats;

  const DetailedStatsGrid({
    Key? key,
    required this.appointmentStats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Determine grid configuration based on screen size
    int crossAxisCount;
    double childAspectRatio;
    double crossAxisSpacing;
    double mainAxisSpacing;
    
    if (isMobile) {
      crossAxisCount = 2;
      childAspectRatio = 1.1;
      crossAxisSpacing = 8;
      mainAxisSpacing = 8;
    } else if (isTablet) {
      crossAxisCount = 2;
      childAspectRatio = 1.3;
      crossAxisSpacing = 12;
      mainAxisSpacing = 12;
    } else {
      crossAxisCount = 4;
      childAspectRatio = 1.2;
      crossAxisSpacing = 16;
      mainAxisSpacing = 16;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          children: [
            DetailedStatCard(
              title: 'Upcoming',
              value: '${appointmentStats['upcoming'] ?? 0}',
              icon: Icons.schedule,
              color: Colors.blue,
            ),
            DetailedStatCard(
              title: 'Pending Approval',
              value: '${appointmentStats['pending'] ?? 0}',
              icon: Icons.pending_actions,
              color: Colors.orange,
            ),
            DetailedStatCard(
              title: 'Completed',
              value: '${appointmentStats['completed'] ?? 0}',
              icon: Icons.check_circle_outline,
              color: Colors.green,
            ),
            DetailedStatCard(
              title: 'Cancelled',
              value: '${appointmentStats['cancelled'] ?? 0}',
              icon: Icons.cancel_outlined,
              color: Colors.red,
            ),
          ],
        );
      },
    );
  }
}

class DetailedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const DetailedStatCard({
    Key? key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);
    final isTablet = ResponsiveHelper.isTablet(context);
    
    // Responsive sizing
    double iconSize = isMobile ? 24 : (isTablet ? 26 : 28);
    double valueSize = isMobile ? 20 : (isTablet ? 22 : 24);
    double titleSize = isMobile ? 12 : (isTablet ? 13 : 14);
    double containerPadding = isMobile ? 12 : (isTablet ? 14 : 16);
    double iconPadding = isMobile ? 8 : (isTablet ? 10 : 12);
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: iconSize),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: TextStyle(
                fontSize: valueSize,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              color: Colors.grey[600],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RecentActivityList extends StatelessWidget {
  const RecentActivityList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: AppointmentService.getRecentAppointmentsStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'No recent activity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            final appointment = Appointment.fromFirestore(snapshot.data!.docs[index]);
            return ActivityItem(appointment: appointment);
          },
        );
      },
    );
  }
}

class ActivityItem extends StatelessWidget {
  final Appointment appointment;

  const ActivityItem({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final activityData = _getActivityData();
    final isMobile = ResponsiveHelper.isMobile(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 4 : 8,
        ),
        leading: CircleAvatar(
          backgroundColor: activityData['color'].withOpacity(0.1),
          radius: isMobile ? 18 : 20,
          child: Icon(
            activityData['icon'],
            color: activityData['color'],
            size: isMobile ? 18 : 20,
          ),
        ),
        title: Text(
          appointment.patientName,
          style: TextStyle(
            fontSize: isMobile ? 14 : 16,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${activityData['action']} • Dr. ${appointment.doctorName}',
          style: TextStyle(
            fontSize: isMobile ? 12 : 14,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? 80 : 120,
          ),
          child: Text(
            appointment.createdAt != null
                ? DateFormat(isMobile ? 'MMM dd\nhh:mm a' : 'MMM dd, hh:mm a')
                    .format(appointment.createdAt!)
                : 'Unknown',
            style: TextStyle(
              fontSize: isMobile ? 10 : 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _getActivityData() {
    switch (appointment.status) {
      case 'pending':
        return {
          'icon': Icons.pending,
          'color': Colors.orange,
          'action': 'New appointment requested',
        };
      case 'upcoming':
        return {
          'icon': Icons.schedule,
          'color': Colors.blue,
          'action': 'Appointment confirmed',
        };
      case 'completed':
        return {
          'icon': Icons.check_circle,
          'color': Colors.green,
          'action': 'Appointment completed',
        };
      case 'cancelled':
        return {
          'icon': Icons.cancel,
          'color': Colors.red,
          'action': 'Appointment cancelled',
        };
      default:
        return {
          'icon': Icons.event_note,
          'color': Colors.grey,
          'action': 'Appointment updated',
        };
    }
  }
}