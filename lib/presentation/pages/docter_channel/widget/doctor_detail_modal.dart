import 'package:flutter/material.dart';
import 'package:mindcare/domain/entities/doctor.dart';

class DoctorDetailsModal extends StatelessWidget {
  final Doctor doctor;
  final bool isInUserList;
  final VoidCallback onAddToFavorites;
  final VoidCallback onRemoveFromFavorites;
  final VoidCallback onCall;

  const DoctorDetailsModal({
    Key? key,
    required this.doctor,
    required this.isInUserList,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
    required this.onCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isLandscape = screenSize.width > screenSize.height;
    
    return DraggableScrollableSheet(
      initialChildSize: isLandscape ? 0.8 : 0.7,
      maxChildSize: isLandscape ? 0.95 : 0.9,
      minChildSize: isLandscape ? 0.6 : 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(isTablet ? 32 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              SizedBox(height: isTablet ? 32 : 20),
              _buildDoctorHeader(context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildAboutSection(context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildInfoCards(context),
              SizedBox(height: isTablet ? 32 : 24),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildDoctorHeader(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 400;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 500) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileImage(isTablet ? 60 : 40),
              SizedBox(width: isTablet ? 24 : 16),
              Expanded(
                child: _buildDoctorInfo(context, isTablet),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildProfileImage(isSmallScreen ? 35 : 40),
              SizedBox(height: isTablet ? 20 : 16),
              _buildDoctorInfo(context, isTablet),
            ],
          );
        }
      },
    );
  }

  Widget _buildProfileImage(double radius) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[300],
      backgroundImage: doctor.profileImage.isNotEmpty 
          ? NetworkImage(doctor.profileImage)
          : null,
      child: doctor.profileImage.isEmpty
          ? Icon(
              Icons.person,
              size: radius * 1.1,
              color: Colors.grey,
            )
          : null,
    );
  }

  Widget _buildDoctorInfo(BuildContext context, bool isTablet) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.name,
          style: TextStyle(
            fontSize: isTablet ? 28 : (isSmallScreen ? 20 : 24),
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          doctor.specialty,
          style: TextStyle(
            fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Row(
          children: [
            Icon(
              Icons.star, 
              size: isTablet ? 24 : (isSmallScreen ? 16 : 20), 
              color: Colors.amber,
            ),
            const SizedBox(width: 4),
            Text(
              '${doctor.rating} (${doctor.reviews} reviews)',
              style: TextStyle(
                fontSize: isTablet ? 16 : (isSmallScreen ? 12 : 14),
              ),
            ),
          ],
        ),
        if (doctor.isOnline) ...[
          SizedBox(height: isTablet ? 12 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 12,
              vertical: isTablet ? 8 : 6,
            ),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Online Now',
              style: TextStyle(
                color: Colors.white,
                fontSize: isTablet ? 14 : (isSmallScreen ? 10 : 12),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 400;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About',
          style: TextStyle(
            fontSize: isTablet ? 22 : (isSmallScreen ? 16 : 18),
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Text(
          doctor.about,
          style: TextStyle(
            fontSize: isTablet ? 16 : (isSmallScreen ? 13 : 14),
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCards(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 400;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              _buildInfoCard(
                'Experience',
                '${doctor.experience} years',
                Icons.work_outline,
                context,
              ),
              SizedBox(height: isTablet ? 16 : 12),
              _buildInfoCard(
                'Consultation Fee',
                '\Rs ${doctor.consultationFee}',
                Icons.attach_money,
                context,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'Experience',
                  '${doctor.experience} years',
                  Icons.work_outline,
                  context,
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: _buildInfoCard(
                  'Consultation Fee',
                  '\Rs ${doctor.consultationFee}',
                  Icons.attach_money,
                  context,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 400;
    
    return Container(
      padding: EdgeInsets.all(isTablet ? 20 : (isSmallScreen ? 12 : 16)),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(
            icon, 
            color: const Color(0xFF6A4C93), 
            size: isTablet ? 32 : (isSmallScreen ? 24 : 28),
          ),
          SizedBox(height: isTablet ? 12 : 8),
          Text(
            title,
            style: TextStyle(
              fontSize: isTablet ? 14 : (isSmallScreen ? 10 : 12),
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: isTablet ? 8 : 4),
          Text(
            value,
            style: TextStyle(
              fontSize: isTablet ? 18 : (isSmallScreen ? 14 : 16),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;
    final isSmallScreen = screenSize.width < 400;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 300) {
          return Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCall();
                  },
                  icon: Icon(
                    Icons.phone,
                    size: isTablet ? 20 : (isSmallScreen ? 16 : 18),
                  ),
                  label: Text(
                    'Call Doctor',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : (isSmallScreen ? 14 : 15),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : (isSmallScreen ? 10 : 12),
                    ),
                    foregroundColor: const Color(0xFF6A4C93),
                  ),
                ),
              ),
              SizedBox(height: isTablet ? 16 : 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isInUserList ? onRemoveFromFavorites : onAddToFavorites,
                  icon: Icon(
                    isInUserList ? Icons.favorite : Icons.favorite_border,
                    size: isTablet ? 20 : (isSmallScreen ? 16 : 18),
                  ),
                  label: Text(
                    isInUserList ? 'Remove from Favorites' : 'Add to Favorites',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : (isSmallScreen ? 14 : 15),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInUserList ? Colors.red : const Color(0xFF6A4C93),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : (isSmallScreen ? 10 : 12),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onCall();
                  },
                  icon: Icon(
                    Icons.phone,
                    size: isTablet ? 20 : (isSmallScreen ? 16 : 18),
                  ),
                  label: Text(
                    'Call Doctor',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : (isSmallScreen ? 12 : 15),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : (isSmallScreen ? 10 : 12),
                    ),
                    foregroundColor: const Color(0xFF6A4C93),
                  ),
                ),
              ),
              SizedBox(width: isTablet ? 16 : 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isInUserList ? onRemoveFromFavorites : onAddToFavorites,
                  icon: Icon(
                    isInUserList ? Icons.favorite : Icons.favorite_border,
                    size: isTablet ? 20 : (isSmallScreen ? 16 : 18),
                  ),
                  label: Text(
                    isInUserList ? 'Remove Favorite' : 'Add Favorite',
                    style: TextStyle(
                      fontSize: isTablet ? 16 : (isSmallScreen ? 12 : 15),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isInUserList ? Colors.red : const Color(0xFF6A4C93),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      vertical: isTablet ? 16 : (isSmallScreen ? 10 : 12),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }
}