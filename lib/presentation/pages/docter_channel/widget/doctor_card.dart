import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/user_details_form.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/doctor_detail_modal.dart';
// Import your UserDetailsForm here - adjust the path according to your project structure
// import 'package:mindcare/presentation/pages/docter_channel/pages/user_details_form.dart';

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isInUserList;
  final VoidCallback onAddToFavorites;
  final VoidCallback onRemoveFromFavorites;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.isInUserList,
    required this.onAddToFavorites,
    required this.onRemoveFromFavorites,
  }) : super(key: key);

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
              ? _buildMobileLayout(context)
              : isTablet
                  ? _buildTabletLayout(context)
                  : _buildDesktopLayout(context),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        _buildDoctorHeader(isMobile: true),
        const SizedBox(height: 12),
        _buildDoctorInfo(isMobile: true),
        const SizedBox(height: 12),
        _buildActionButtons(context, isMobile: true),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
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
              child: _buildActionButtons(context, isTablet: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
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
          child: _buildActionButtons(context, isDesktop: true),
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
          backgroundImage: doctor.profileImage.isNotEmpty
              ? NetworkImage(doctor.profileImage)
              : const NetworkImage('https://firebasestorage.googleapis.com/v0/b/mindcare-e9b55.firebasestorage.app/o/doctor-1295571_1280.png?alt=media&token=78b0acbb-a308-4d66-a326-3824a6eec953'),
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
                  // if (doctor.isOnline) _buildOnlineBadge(isMobile: isMobile),
                  // SizedBox(width: isMobile ? 4 : 8),
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

  

  Widget _buildRatingAndExperience({bool isMobile = false}) {
    final textSize = isMobile ? 12.0 : 14.0;
    final smallTextSize = isMobile ? 10.0 : 12.0;

    return Wrap(
      spacing: isMobile ? 8 : 12,
      runSpacing: 4,
      children: [
        // Row(
        //   mainAxisSize: MainAxisSize.min,
        //   children: [
        //     Icon(
        //       Icons.star,
        //       size: isMobile ? 14 : 16,
        //       color: Colors.amber,
        //     ),
        //     const SizedBox(width: 4),
        //     Text(
        //       '${doctor.rating}',
        //       style: TextStyle(
        //         fontSize: textSize,
        //         fontWeight: FontWeight.w500,
        //       ),
        //     ),
        //     const SizedBox(width: 4),
        //     Text(
        //       '(${doctor.reviews} reviews)',
        //       style: TextStyle(
        //         fontSize: smallTextSize,
        //         color: Colors.grey[600],
        //       ),
        //     ),
        //   ],
        // ),
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

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.all(isMobile ? 8 : 12),
            decoration: BoxDecoration(
              color: const Color(0xFF6A4C93).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
          ),
        ),

        // Expanded(
        //   child: Container(
        //     padding: EdgeInsets.all(isMobile ? 8 : 12),
        //     decoration: BoxDecoration(
        //       color: Colors.green.withOpacity(0.1),
        //       borderRadius: BorderRadius.circular(8),
        //     ),
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //       children: [
        //         Column(
        //           crossAxisAlignment: CrossAxisAlignment.start,
        //           children: [
        //             Text(
        //               'Mobile Number',
        //               style: TextStyle(
        //                 fontSize: labelSize,
        //                 color: Colors.grey[600],
        //               ),
        //             ),
        //             const SizedBox(height: 2),
        //             Text(
        //               doctor.mobileNumber ?? '+94 71 234 5678',
        //               style: TextStyle(
        //                 fontSize: valueSize,
        //                 fontWeight: FontWeight.bold,
        //                 color: Colors.green[700],
        //               ),
        //             ),
        //           ],
        //         ),
        //         if (!isMobile)
        //           Icon(
        //             Icons.phone,
        //             color: Colors.green[700],
        //             size: isDesktop ? 24 : 20,
        //           ),
        //       ],
        //     ),
        //   ),
        // ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context, {
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
              onPressed: () => _navigateToUserDetailsForm(context),
              icon: Icon(Icons.video_call, size: iconSize),
              label: Text(
                'Channel Doctor',
                style: TextStyle(fontSize: fontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // const SizedBox(height: 8),
          // SizedBox(
          //   width: double.infinity,
          //   height: buttonHeight,
          //   child: ElevatedButton.icon(
          //     onPressed: () => _makePhoneCall(doctor.mobileNumber ?? '+94712345678'),
          //     icon: Icon(Icons.phone, size: iconSize),
          //     label: Text(
          //       'Call Doctor',
          //       style: TextStyle(fontSize: fontSize),
          //     ),
          //     style: ElevatedButton.styleFrom(
          //       backgroundColor: Colors.green,
          //       foregroundColor: Colors.white,
          //     ),
          //   ),
          // ),
          // const SizedBox(height: 8),
          // SizedBox(
          //   width: double.infinity,
          //   height: buttonHeight,
          //   child: OutlinedButton.icon(
          //     onPressed: () => _copyNumberToClipboard(doctor.mobileNumber ?? '+94712345678'),
          //     icon: Icon(Icons.content_copy, size: iconSize),
          //     label: Text(
          //       'Get Number',
          //       style: TextStyle(fontSize: fontSize),
          //     ),
          //     style: OutlinedButton.styleFrom(
          //       foregroundColor: const Color(0xFF6A4C93),
          //     ),
          //   ),
          // ),
        ],
      );
    }

    if (isTablet) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton.icon(
              onPressed: () => _navigateToUserDetailsForm(context),
              icon: Icon(Icons.video_call, size: iconSize),
              label: Text(
                'Channel Doctor',
                style: TextStyle(fontSize: fontSize),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6A4C93),
                foregroundColor: Colors.white,
              ),
            ),
          ),
          // const SizedBox(height: 8),
          // Row(
          //   children: [
          //     Expanded(
          //       child: SizedBox(
          //         height: buttonHeight,
          //         child: OutlinedButton.icon(
          //           onPressed: () => _copyNumberToClipboard(doctor.mobileNumber ?? '+94712345678'),
          //           icon: Icon(Icons.content_copy, size: iconSize),
          //           label: Text(
          //             'Get Number',
          //             style: TextStyle(fontSize: fontSize),
          //           ),
          //           style: OutlinedButton.styleFrom(
          //             foregroundColor: const Color(0xFF6A4C93),
          //           ),
          //         ),
          //       ),
          //     ),
          //     const SizedBox(width: 8),
          //     Expanded(
          //       child: SizedBox(
          //         height: buttonHeight,
          //         child: ElevatedButton.icon(
          //           onPressed: () => _makePhoneCall(doctor.mobileNumber ?? '+94712345678'),
          //           icon: Icon(Icons.phone, size: iconSize),
          //           label: Text(
          //             'Call',
          //             style: TextStyle(fontSize: fontSize),
          //           ),
          //           style: ElevatedButton.styleFrom(
          //             backgroundColor: Colors.green,
          //             foregroundColor: Colors.white,
          //           ),
          //         ),
          //       ),
          //     ),
          //   ],
          // ),
        ],
      );
    }

    // Mobile layout
    return Column(
      children: [
        
        Row(
          children: [
            // Expanded(
            //   child: SizedBox(
            //     height: buttonHeight,
            //     child: OutlinedButton.icon(
            //       onPressed: () => _copyNumberToClipboard(doctor.mobileNumber ?? '+94712345678'),
            //       icon: Icon(Icons.content_copy, size: iconSize),
            //       label: Text(
            //         'Get Number',
            //         style: TextStyle(fontSize: fontSize),
            //       ),
            //       style: OutlinedButton.styleFrom(
            //         foregroundColor: const Color(0xFF6A4C93),
            //       ),
            //     ),
            //   ),
            // ),
            // const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                height: buttonHeight,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToUserDetailsForm(context),
                  icon: Icon(Icons.bookmark_outline, size: iconSize),
                  label: Text(
                    'Channel Doctor',
                    style: TextStyle(fontSize: fontSize),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToUserDetailsForm(BuildContext context) {
    // Option 1: If you have the UserDetailsForm available, use this:

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsForm(doctor: doctor),
      ),
    );

    
    // Option 2: Temporary placeholder until you set up the UserDetailsForm
    // showDialog(
    //   context: context,
    //   builder: (context) => AlertDialog(
    //     title: const Text('Channel Doctor'),
    //     content: Text('Booking appointment with ${doctor.name}\n\nPlease create the UserDetailsForm widget and update the import statement.'),
    //     actions: [
    //       TextButton(
    //         onPressed: () => Navigator.of(context).pop(),
    //         child: const Text('OK'),
    //       ),
    //     ],
    //   ),
    // );
  }

  void _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
    }
  }

  void _copyNumberToClipboard(String phoneNumber) async {
    await Clipboard.setData(ClipboardData(text: phoneNumber));
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
        onCall: () => _makePhoneCall(doctor.mobileNumber ?? '+94712345678'),
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
    final String amountStr = amount.toString();
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return amountStr.replaceAllMapped(reg, (Match match) => '${match[1]},');
  }
}