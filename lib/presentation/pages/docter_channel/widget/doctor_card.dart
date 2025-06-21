import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/doctor_detail_modal.dart';


class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isInUserList;
  final VoidCallback onAddToFavorites;
  final VoidCallback onRemoveFromFavorites;
  final VoidCallback onChat;
  final VoidCallback onBookAppointment;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isInUserList,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.onChat,
    required this.onBookAppointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDoctorDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildDoctorHeader(),
              const SizedBox(height: 16),
              _buildDoctorInfo(),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          backgroundImage: doctor.profileImage.isNotEmpty 
              ? NetworkImage(doctor.profileImage)
              : null,
          child: doctor.profileImage.isEmpty
              ? const Icon(
                  Icons.person,
                  size: 35,
                  color: Colors.grey,
                )
              : null,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doctor.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (doctor.isOnline) _buildOnlineBadge(),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: isInUserList ? onRemoveFromFavorites : onAddToFavorites,
                    icon: Icon(
                      isInUserList ? Icons.favorite : Icons.favorite_border,
                      color: isInUserList ? Colors.red : Colors.grey,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialty,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              _buildRatingAndExperience(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Online',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingAndExperience() {
    return Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          '${doctor.rating}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '(${doctor.reviews} reviews)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${doctor.experience} years exp.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation Fee',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'LKR ${_formatCurrency(doctor.consultationFee)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6A4C93),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Next Available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                _formatAvailability(doctor.nextAvailable),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onChat,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text('Chat'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6A4C93),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onBookAppointment,
            icon: const Icon(Icons.calendar_today),
            label: const Text('Book'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6A4C93),
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  void _showDoctorDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DoctorDetailsModal(
        doctor: doctor,
        isInUserList: isInUserList,
        onAddToFavorites: onAddToFavorites,
        onRemoveFromFavorites: onRemoveFromFavorites,
        onChat: onChat,
        onBookAppointment: onBookAppointment,
      ),
    );
  }

  String _formatAvailability(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours';
    } else {
      return '${difference.inDays} days';
    }
  }

  String _formatCurrency(int amount) {
    // Format Sri Lankan Rupees with commas
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}