import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mindcare/data/datasources/appiment_datasource.dart';
import 'package:mindcare/data/models/appoiment_modal.dart';


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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.2,
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
    return Container(
      padding: const EdgeInsets.all(16),
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
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
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
            child: Text('No recent activity'),
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

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: activityData['color'].withOpacity(0.1),
          child: Icon(
            activityData['icon'],
            color: activityData['color'],
            size: 20,
          ),
        ),
        title: Text(appointment.patientName),
        subtitle: Text(
          '${activityData['action']} • Dr. ${appointment.doctorName}',
        ),
        trailing: Text(
          appointment.createdAt != null
              ? DateFormat('MMM dd, hh:mm a').format(appointment.createdAt!)
              : 'Unknown',
          style: const TextStyle(fontSize: 12),
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