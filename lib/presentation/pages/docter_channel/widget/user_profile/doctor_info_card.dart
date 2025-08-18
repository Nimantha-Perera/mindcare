import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_profile/currency_formatter.dart';

class DoctorInfoCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorInfoCard({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
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
      child: isSmallScreen ? _buildMobileLayout() : _buildDesktopLayout(),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        Row(
          children: [
            _buildAvatar(30),
            const SizedBox(width: 16),
            Expanded(child: _buildDoctorInfo(false)),
          ],
        ),
        const SizedBox(height: 16),
        _buildFeeContainer(true),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        _buildAvatar(35),
        const SizedBox(width: 20),
        Expanded(child: _buildDoctorInfo(true)),
        const SizedBox(width: 16),
        _buildFeeContainer(false),
      ],
    );
  }

  Widget _buildAvatar(double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: doctor.profileImage.isNotEmpty
          ? NetworkImage(doctor.profileImage)
          : const NetworkImage(
              'https://firebasestorage.googleapis.com/v0/b/mindcare-e9b55.firebasestorage.app/o/doctor-1295571_1280.png?alt=media&token=78b0acbb-a308-4d66-a326-3824a6eec953',
            ),
    );
  }

  Widget _buildDoctorInfo(bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          doctor.name,
          style: TextStyle(
            fontSize: isDesktop ? 20 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          doctor.specialty,
          style: TextStyle(
            fontSize: isDesktop ? 16 : 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            Text(
              '${doctor.rating} (${doctor.reviews} reviews)',
              style: TextStyle(fontSize: isDesktop ? 14 : 12),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeContainer(bool fullWidth) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4C93).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'LKR ${CurrencyFormatter.format(doctor.consultationFee)}',
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Color(0xFF6A4C93),
          fontSize: 16,
        ),
        textAlign: fullWidth ? TextAlign.center : TextAlign.start,
      ),
    );
  }
}