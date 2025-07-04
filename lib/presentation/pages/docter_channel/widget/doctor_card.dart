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

  // Dummy profile images for doctors
  static const List<String> _dummyImages = [
    'https://images.unsplash.com/photo-1612349317150-e413f6a5b16d?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1582750433449-648ed127bb54?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1594824863349-d9b2918d7234?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1607990281513-2c110a25bd8c?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1638202993928-7267aad84c31?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1551601651-2a8555f1a136?w=200&h=200&fit=crop&crop=face',
    'https://images.unsplash.com/photo-1622253692010-333f2da6031d?w=200&h=200&fit=crop&crop=face',
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 768;
    final isMobile = screenWidth < 600;

    return Card(
      margin: EdgeInsets.only(
        bottom: isMobile ? 12 : 16,
        left: isMobile ? 8 : 0,
        right: isMobile ? 8 : 0,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      ),
      child: InkWell(
        onTap: () => _showDoctorDetails(context),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
          child: isMobile
              ? _buildMobileLayout()
              : isTablet
                  ? _buildTabletLayout()
                  : _buildDesktopLayout(),
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildDoctorHeader(isMobile: true),
        const SizedBox(height: 12),
        _buildDoctorInfo(isMobile: true),
        const SizedBox(height: 12),
        _buildActionButtons(isMobile: true),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Column(
      children: [
        _buildDoctorHeader(isTablet: true),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildDoctorInfo(isTablet: true)),
            const SizedBox(width: 16),
            SizedBox(
              width: 200,
              child: _buildActionButtons(isTablet: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildDoctorHeader(isDesktop: true),
              const SizedBox(height: 16),
              _buildDoctorInfo(isDesktop: true),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 1,
          child: _buildActionButtons(isDesktop: true),
        ),
      ],
    );
  }

  Widget _buildDoctorHeader({
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final avatarRadius = isMobile ? 25.0 : isTablet ? 32.0 : 35.0;
    final nameSize = isMobile ? 16.0 : isTablet ? 18.0 : 20.0;
    final specialtySize = isMobile ? 12.0 : isTablet ? 14.0 : 14.0;

    return Row(
      children: [
        CircleAvatar(
          radius: avatarRadius,
          backgroundColor: Colors.grey[300],
          backgroundImage: _getDummyImage(),
          child: null,
        ),
        SizedBox(width: isMobile ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      doctor.name,
                      style: TextStyle(
                        fontSize: nameSize,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: isMobile ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (doctor.isOnline) _buildOnlineBadge(isMobile: isMobile),
                  SizedBox(width: isMobile ? 4 : 8),
                  IconButton(
                    onPressed: isInUserList ? onRemoveFromFavorites : onAddToFavorites,
                    icon: Icon(
                      isInUserList ? Icons.favorite : Icons.favorite_border,
                      color: isInUserList ? Colors.red : Colors.grey,
                      size: isMobile ? 20 : 24,
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
                  fontSize: specialtySize,
                  color: Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              _buildRatingAndExperience(isMobile: isMobile),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOnlineBadge({bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 6 : 8,
        vertical: isMobile ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
      ),
      child: Text(
        'Online',
        style: TextStyle(
          color: Colors.white,
          fontSize: isMobile ? 10 : 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildRatingAndExperience({bool isMobile = false}) {
    final textSize = isMobile ? 12.0 : 14.0;
    final smallTextSize = isMobile ? 10.0 : 12.0;

    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: 4,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: isMobile ? 14 : 16,
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              '${doctor.rating}',
              style: TextStyle(
                fontSize: textSize,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '(${doctor.reviews} reviews)',
              style: TextStyle(
                fontSize: smallTextSize,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Text(
          '${doctor.experience} years exp.',
          style: TextStyle(
            fontSize: smallTextSize,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorInfo({
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final labelSize = isMobile ? 11.0 : 12.0;
    final valueSize = isMobile ? 14.0 : 16.0;

    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        color: const Color(0xFF6A4C93).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Consultation Fee',
                style: TextStyle(
                  fontSize: labelSize,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'LKR ${_formatCurrency(doctor.consultationFee)}',
                style: TextStyle(
                  fontSize: valueSize,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF6A4C93),
                ),
              ),
            ],
          ),
          if (!isMobile)
            Icon(
              Icons.monetization_on_outlined,
              color: const Color(0xFF6A4C93),
              size: isDesktop ? 24 : 20,
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons({
    bool isMobile = false,
    bool isTablet = false,
    bool isDesktop = false,
  }) {
    final buttonHeight = isMobile ? 36.0 : 40.0;
    final fontSize = isMobile ? 12.0 : 14.0;
    final iconSize = isMobile ? 16.0 : 18.0;

    if (isDesktop) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: onBookAppointment,
              icon: Icon(Icons.calendar_today, size: iconSize),
              label: Text(
                'Book Appointment',
                style: TextStyle(fontSize: fontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onChat,
              icon: Icon(Icons.chat_bubble_outline, size: iconSize),
              label: Text(
                'Chat Now',
                style: TextStyle(fontSize: fontSize),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6A4C93),
              ),
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: OutlinedButton.icon(
              onPressed: onChat,
              icon: Icon(Icons.chat_bubble_outline, size: iconSize),
              label: Text(
                'Chat',
                style: TextStyle(fontSize: fontSize),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF6A4C93),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: SizedBox(
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: onBookAppointment,
              icon: Icon(Icons.calendar_today, size: iconSize),
              label: Text(
                'Book',
                style: TextStyle(fontSize: fontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
              ),
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

  NetworkImage _getDummyImage() {
    // Use doctor's name hash to consistently assign the same image
    final imageIndex = doctor.name.hashCode.abs() % _dummyImages.length;
    return NetworkImage(_dummyImages[imageIndex]);
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