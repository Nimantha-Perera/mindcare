import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/cubit/doctor_cubit.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/doctor_card.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/empty_state.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/filter_section.dart';


class DoctorChannelScreen extends StatefulWidget {
  const DoctorChannelScreen({Key? key}) : super(key: key);

  @override
  State<DoctorChannelScreen> createState() => _DoctorChannelScreenState();
}

class _DoctorChannelScreenState extends State<DoctorChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _specialties = [
    'All',
    'Clinical Psychology',
    'Psychiatry',
    'Counseling Psychology',
    'Behavioral Therapy',
    'Cognitive Therapy',
    'Stress Management',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load doctors when screen initializes
    context.read<DoctorCubit>().loadDoctors();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Mental Health Doctors',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6A4C93),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Find Doctors'),
            Tab(text: 'My Doctors'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindDoctorsTab(),
          _buildMyDoctorsTab(),
        ],
      ),
    );
  }

  Widget _buildFindDoctorsTab() {
    return BlocConsumer<DoctorCubit, DoctorState>(
      listener: (context, state) {
        if (state is DoctorError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            FilterSection(
              specialties: _specialties,
              selectedSpecialty: state is DoctorLoaded ? state.selectedSpecialty : 'All',
              isOnlineOnly: state is DoctorLoaded ? state.isOnlineOnly : false,
              onSpecialtyChanged: (specialty) {
                context.read<DoctorCubit>().filterDoctors(specialty: specialty);
              },
              onOnlineFilterChanged: (isOnlineOnly) {
                context.read<DoctorCubit>().filterDoctors(isOnlineOnly: isOnlineOnly);
              },
            ),
            Expanded(
              child: _buildDoctorsList(state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMyDoctorsTab() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (state is DoctorLoaded) {
          if (state.userDoctors.isEmpty) {
            return const EmptyState(
              message: 'No saved doctors yet',
              subtitle: 'Add doctors to your list from the Find Doctors tab',
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.userDoctors.length,
            itemBuilder: (context, index) {
              return DoctorCard(
                doctor: state.userDoctors[index],
                isInUserList: true,
                onAddToFavorites: () => _addToFavorites(state.userDoctors[index]),
                onRemoveFromFavorites: () => _removeFromFavorites(state.userDoctors[index]),
                onChat: () => _startChat(state.userDoctors[index]),
                // onBookAppointment: () => _bookAppointment(state.userDoctors[index]),
              );
            },
          );
        }
        
        return const EmptyState(
          message: 'Something went wrong',
          subtitle: 'Please try again later',
        );
      },
    );
  }

  Widget _buildDoctorsList(DoctorState state) {
    if (state is DoctorLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF6A4C93),
        ),
      );
    }

    if (state is DoctorLoaded) {
      if (state.doctors.isEmpty) {
        return const EmptyState(
          message: 'No doctors found',
          subtitle: 'Try adjusting your filters',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorCubit>().loadDoctors(
            specialty: state.selectedSpecialty,
            isOnlineOnly: state.isOnlineOnly,
          );
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: state.doctors.length,
          itemBuilder: (context, index) {
            final doctor = state.doctors[index];
            final isInUserList = state.userDoctors.any((d) => d.id == doctor.id);
            
            return DoctorCard(
              doctor: doctor,
              isInUserList: isInUserList,
              onAddToFavorites: () => _addToFavorites(doctor),
              onRemoveFromFavorites: () => _removeFromFavorites(doctor),
              onChat: () => _startChat(doctor),
              // onBookAppointment: () => _bookAppointment(doctor),
            );
          },
        ),
      );
    }

    return const EmptyState(
      message: 'Something went wrong',
      subtitle: 'Please try again later',
    );
  }

  void _addToFavorites(Doctor doctor) {
    context.read<DoctorCubit>().addDoctorToUser(doctor.id);
    _showSnackBar('${doctor.name} added to your doctors');
  }

  void _removeFromFavorites(Doctor doctor) {
    context.read<DoctorCubit>().removeDoctorFromUser(doctor.id);
    _showSnackBar('${doctor.name} removed from your doctors');
  }

  void _startChat(Doctor doctor) {
    // TODO: Navigate to chat screen
    _showSnackBar('Starting chat with ${doctor.name}');
  }

  void _bookAppointment(Doctor doctor) {
    // TODO: Navigate to appointment booking screen
    _showSnackBar('Booking appointment with ${doctor.name}');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF6A4C93),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}