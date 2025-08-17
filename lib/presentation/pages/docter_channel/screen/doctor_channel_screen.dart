import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mindcare/domain/entities/doctor.dart';
import 'package:mindcare/presentation/cubit/doctor_cubit.dart';
import 'package:mindcare/presentation/pages/docter_channel/widget/appoiment_section.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  String _searchQuery = '';

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
    _tabController = TabController(length: 3, vsync: this);

    context.read<DoctorCubit>().loadDoctors();

    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  List<Doctor> _filterDoctorsBySearch(List<Doctor> doctors) {
    if (_searchQuery.isEmpty) return doctors;

    final query = _searchQuery.toLowerCase();
    return doctors.where((doctor) {
      return doctor.name.toLowerCase().contains(query) ||
          doctor.specialty.toLowerCase().contains(query) ||
          (doctor.about.toLowerCase().contains(query));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFindDoctorsTab(),
          _buildMyDoctorsTab(),
          AppointmentSections()
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: _isSearching
          ? _buildSearchField()
          : const Text(
              'Doctors',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
      backgroundColor: const Color(0xFF6A4C93),
      elevation: 0,
      actions: _buildAppBarActions(),
      bottom: _isSearching
          ? null
          : TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Find Doctors'),
                Tab(text: 'My Doctors'),
                Tab(
                  text: 'My Appoiments',
                )
              ],
            ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search doctors, specialties...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        border: InputBorder.none,
        suffixIcon: _searchQuery.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white),
                onPressed: _clearSearch,
              )
            : null,
      ),
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
    );
  }

  List<Widget> _buildAppBarActions() {
    if (_isSearching) {
      return [
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _toggleSearch,
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.search, color: Colors.white),
        onPressed: _toggleSearch,
      ),
      // IconButton(
      //   icon: const Icon(Icons.notifications_outlined, color: Colors.white),
      //   onPressed: () {
      //     // TODO: Implement notifications
      //     Navigator.push(
      //       context,
      //       MaterialPageRoute(
      //         builder: (context) => const AppointmentSections(),
      //       ),
      //     );
      //   },
      // ),
    ];
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
            if (_isSearching && _searchQuery.isNotEmpty)
              _buildSearchResultsHeader(),
            if (!_isSearching)
              FilterSection(
                specialties: _specialties,
                selectedSpecialty:
                    state is DoctorLoaded ? state.selectedSpecialty : 'All',
                isOnlineOnly:
                    state is DoctorLoaded ? state.isOnlineOnly : false,
                onSpecialtyChanged: (specialty) {
                  context
                      .read<DoctorCubit>()
                      .filterDoctors(specialty: specialty);
                },
                onOnlineFilterChanged: (isOnlineOnly) {
                  context
                      .read<DoctorCubit>()
                      .filterDoctors(isOnlineOnly: isOnlineOnly);
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

  Widget _buildSearchResultsHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey[100],
      child: Text(
        'Search results for "$_searchQuery"',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMyDoctorsTab() {
    return BlocBuilder<DoctorCubit, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is DoctorLoaded) {
          final filteredDoctors = _filterDoctorsBySearch(state.userDoctors);

          if (state.userDoctors.isEmpty) {
            return const EmptyState(
              message: 'No saved doctors yet',
              subtitle: 'Add doctors to your list from the Find Doctors tab',
            );
          }

          if (filteredDoctors.isEmpty && _searchQuery.isNotEmpty) {
            return EmptyState(
              message: 'No doctors found',
              subtitle: 'No saved doctors match "$_searchQuery"',
            );
          }

          return Column(
            children: [
              if (_searchQuery.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.grey[100],
                  child: Text(
                    '${filteredDoctors.length} of ${state.userDoctors.length} doctors found',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return DoctorCard(
                      doctor: filteredDoctors[index],
                      isInUserList: true,
                      onAddToFavorites: () =>
                          _addToFavorites(filteredDoctors[index]),
                      onRemoveFromFavorites: () =>
                          _removeFromFavorites(filteredDoctors[index]),
                    );
                  },
                ),
              ),
            ],
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
      // Apply search filter to all doctors
      final filteredDoctors = _filterDoctorsBySearch(state.doctors);

      if (state.doctors.isEmpty) {
        return const EmptyState(
          message: 'No doctors found',
          subtitle: 'Try adjusting your filters',
        );
      }

      if (filteredDoctors.isEmpty && _searchQuery.isNotEmpty) {
        return EmptyState(
          message: 'No doctors found',
          subtitle: 'No doctors match "$_searchQuery"',
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<DoctorCubit>().loadDoctors(
                specialty: state.selectedSpecialty,
                isOnlineOnly: state.isOnlineOnly,
              );
        },
        child: Column(
          children: [
            // Show results count when searching
            if (_searchQuery.isNotEmpty)
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${filteredDoctors.length} doctors found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: filteredDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = filteredDoctors[index];
                  final isInUserList =
                      state.userDoctors.any((d) => d.id == doctor.id);

                  return DoctorCard(
                    doctor: doctor,
                    isInUserList: isInUserList,
                    onAddToFavorites: () => _addToFavorites(doctor),
                    onRemoveFromFavorites: () => _removeFromFavorites(doctor),
                  );
                },
              ),
            ),
          ],
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
