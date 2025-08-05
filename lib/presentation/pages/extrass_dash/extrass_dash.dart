import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Import your Clean Architecture files

import 'package:mindcare/data/datasources/firestore_doctore_datasource.dart';
import 'package:mindcare/data/repositories/doctor_repo_impl.dart';

import 'package:mindcare/domain/usecases/get_doctors_usecase.dart';
import 'package:mindcare/domain/usecases/manage_user_doctors_usecase.dart';
import 'package:mindcare/presentation/cubit/doctor_cubit.dart';
import 'package:mindcare/presentation/pages/docter_channel/screen/doctor_channel_screen.dart';


import 'package:mindcare/presentation/pages/home/widgets/home_card.dart';
import 'package:mindcare/presentation/pages/sos/sos_page.dart';
import 'package:mindcare/utils/firestore_debug.dart';

class ExtrasDashboard extends StatelessWidget {
  const ExtrasDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1B5E20),  // Deep green
              Color(0xFF2E7D32),  // Medium green
              Color(0xFF4CAF50).withOpacity(0.8),  // Lighter green
            ],
          ),
        ),
        child: Stack(
          children: [
            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -30,
              left: -30,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with back button and debug button
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ),
                        const Spacer(),
                        // Debug button
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.red.withOpacity(0.2),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.settings, color: Colors.white),
                            onPressed: () => _navigateToDebug(context),
                            tooltip: 'Firestore Debug',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Title
                    const Center(
                      child: Text(
                        'Extras',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black26,
                              offset: Offset(2.0, 2.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Centered cards
                    Expanded(
                      child: Center(
                        child: _buildCardList(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardList(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        HomeCardButton(
          label: "Channel Doctor",
          leftIcon: Icons.format_quote,
          rightImageAsset: 'assets/icons/mindfulness1.png',
          leftBackgroundColor: const Color(0xFF2E7D32),
          onTap: () => _navigateToDoctorChannel(context),
        ),
        const SizedBox(height: 20),
        HomeCardButton(
          label: "SOS",
          leftImageAsset: 'assets/icons/emergency-call.png',
          rightIcon: Icons.check_circle_outline,
          rightBackgroundColor: const Color.fromARGB(255, 163, 19, 0),
          onTap: () => _navigateToSOS(context),
        ),
        const SizedBox(height: 20),
        // Debug option (only in debug mode)
        if (const bool.fromEnvironment('dart.vm.product') == false)
          HomeCardButton(
            label: "Debug Firestore",
            leftIcon: Icons.bug_report,
            rightIcon: Icons.settings,
            leftBackgroundColor: Colors.orange,
            onTap: () => _navigateToDebug(context),
          ),
      ],
    );
  }

  void _navigateToDebug(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const FirestoreDebugScreen(),
      ),
    );
  }

  void _navigateToDoctorChannel(BuildContext context) {
    try {
      // Show loading first
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Setting up Doctor Channel...'),
            ],
          ),
        ),
      );

      // Create dependencies manually
      final firestore = FirebaseFirestore.instance;
      final dataSource = FirestoreDoctorDataSourceImpl(firestore: firestore);
      final repository = DoctorRepositoryImpl(dataSource);
      
      // Create use cases
      final getDoctorsUseCase = GetDoctorsUseCase(repository);
      final getUserDoctorsUseCase = GetUserDoctorsUseCase(repository);
      final addToUserDoctorsUseCase = AddToUserDoctorsUseCase(repository);
      final removeFromUserDoctorsUseCase = RemoveFromUserDoctorsUseCase(repository);
      final checkDoctorInUserListUseCase = CheckDoctorInUserListUseCase(repository);

      // Create cubit with all dependencies
      final doctorCubit = DoctorCubit(
        getDoctorsUseCase: getDoctorsUseCase,
        getUserDoctorsUseCase: getUserDoctorsUseCase,
        addToUserDoctorsUseCase: addToUserDoctorsUseCase,
        removeFromUserDoctorsUseCase: removeFromUserDoctorsUseCase,
        checkDoctorInUserListUseCase: checkDoctorInUserListUseCase,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Navigate with the manually created cubit
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider<DoctorCubit>.value(
            value: doctorCubit,
            child: const DoctorChannelScreen(),
          ),
        ),
      );
    } catch (e) {
      // Close loading dialog if open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Show error to user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error opening Doctor Channel: $e'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Debug',
            textColor: Colors.white,
            onPressed: () => _navigateToDebug(context),
          ),
        ),
      );
      print('Error navigating to Doctor Channel: $e');
    }
  }

  void _navigateToSOS(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SOSPage()),
    );
  }
}