import 'package:flutter/material.dart';

class DoctorChannelScreen extends StatefulWidget {
  const DoctorChannelScreen({Key? key}) : super(key: key);

  @override
  State<DoctorChannelScreen> createState() => _DoctorChannelScreenState();
}

class _DoctorChannelScreenState extends State<DoctorChannelScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedSpecialty = 'All';
  bool _isOnlineOnly = false;

  final List<String> _specialties = [
    'All',
    'Clinical Psychology',
    'Psychiatry',
    'Counseling Psychology',
    'Behavioral Therapy',
    'Cognitive Therapy',
    'Stress Management',
  ];

  final List<Doctor> _doctors = [
    Doctor(
      id: '1',
      name: 'Dr. Sarah Mitchell',
      specialty: 'Clinical Psychology',
      rating: 4.9,
      reviews: 156,
      experience: 12,
      isOnline: true,
      consultationFee: 120,
      profileImage: 'assets/images/doctor1.jpg',
      about: 'Specialized clinical psychologist with expertise in depression, anxiety, and stress management. Uses cognitive-behavioral therapy and mindfulness techniques.',
      nextAvailable: DateTime.now().add(Duration(hours: 2)),
    ),
    Doctor(
      id: '2',
      name: 'Dr. Michael Thompson',
      specialty: 'Psychiatry',
      rating: 4.8,
      reviews: 203,
      experience: 15,
      isOnline: false,
      consultationFee: 180,
      profileImage: 'assets/images/doctor2.jpg',
      about: 'Board-certified psychiatrist specializing in mood disorders, depression treatment, and psychiatric medication management.',
      nextAvailable: DateTime.now().add(Duration(days: 1)),
    ),
    Doctor(
      id: '3',
      name: 'Dr. Emily Rodriguez',
      specialty: 'Counseling Psychology',
      rating: 4.9,
      reviews: 89,
      experience: 8,
      isOnline: true,
      consultationFee: 100,
      profileImage: 'assets/images/doctor3.jpg',
      about: 'Compassionate counseling psychologist focused on stress management, emotional regulation, and life transitions.',
      nextAvailable: DateTime.now().add(Duration(minutes: 30)),
    ),
    Doctor(
      id: '4',
      name: 'Dr. James Wilson',
      specialty: 'Behavioral Therapy',
      rating: 4.7,
      reviews: 134,
      experience: 10,
      isOnline: true,
      consultationFee: 140,
      profileImage: 'assets/images/doctor4.jpg',
      about: 'Expert in behavioral therapy techniques for depression and stress-related disorders. Specializes in habit formation and behavior modification.',
      nextAvailable: DateTime.now().add(Duration(hours: 4)),
    ),
    Doctor(
      id: '5',
      name: 'Dr. Lisa Chen',
      specialty: 'Cognitive Therapy',
      rating: 4.8,
      reviews: 167,
      experience: 11,
      isOnline: false,
      consultationFee: 130,
      profileImage: 'assets/images/doctor5.jpg',
      about: 'Cognitive therapist specializing in thought pattern restructuring for depression and anxiety. Expert in CBT and mindfulness-based interventions.',
      nextAvailable: DateTime.now().add(Duration(days: 2)),
    ),
    Doctor(
      id: '6',
      name: 'Dr. Robert Kumar',
      specialty: 'Stress Management',
      rating: 4.6,
      reviews: 112,
      experience: 7,
      isOnline: true,
      consultationFee: 110,
      profileImage: 'assets/images/doctor6.jpg',
      about: 'Stress management specialist focusing on workplace stress, burnout prevention, and relaxation techniques for mental wellness.',
      nextAvailable: DateTime.now().add(Duration(hours: 6)),
    ),
    Doctor(
      id: '7',
      name: 'Dr. Amanda Foster',
      specialty: 'Psychiatry',
      rating: 4.9,
      reviews: 198,
      experience: 14,
      isOnline: true,
      consultationFee: 170,
      profileImage: 'assets/images/doctor7.jpg',
      about: 'Psychiatrist with extensive experience in treating major depressive disorder, bipolar disorder, and stress-induced mental health conditions.',
      nextAvailable: DateTime.now().add(Duration(hours: 1)),
    ),
    Doctor(
      id: '8',
      name: 'Dr. David Martinez',
      specialty: 'Clinical Psychology',
      rating: 4.7,
      reviews: 145,
      experience: 9,
      isOnline: false,
      consultationFee: 125,
      profileImage: 'assets/images/doctor8.jpg',
      about: 'Clinical psychologist specializing in trauma-informed care, depression treatment, and stress resilience building through evidence-based practices.',
      nextAvailable: DateTime.now().add(Duration(hours: 8)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Doctor> get _filteredDoctors {
    List<Doctor> filtered = _doctors;

    if (_selectedSpecialty != 'All') {
      filtered = filtered.where((doctor) => doctor.specialty == _selectedSpecialty).toList();
    }

    if (_isOnlineOnly) {
      filtered = filtered.where((doctor) => doctor.isOnline).toList();
    }

    return filtered;
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
              // Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              // Implement notifications
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
    return Column(
      children: [
        _buildFilterSection(),
        Expanded(
          child: _filteredDoctors.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _filteredDoctors.length,
                  itemBuilder: (context, index) {
                    return _buildDoctorCard(_filteredDoctors[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMyDoctorsTab() {
    final myDoctors = _doctors.take(2).toList(); // Simulate user's doctors
    return myDoctors.isEmpty
        ? _buildEmptyState(message: 'No saved doctors yet')
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: myDoctors.length,
            itemBuilder: (context, index) {
              return _buildDoctorCard(myDoctors[index], isMyDoctor: true);
            },
          );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter by Mental Health Specialty',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _specialties.length,
              itemBuilder: (context, index) {
                final specialty = _specialties[index];
                final isSelected = _selectedSpecialty == specialty;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FilterChip(
                    label: Text(specialty),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedSpecialty = selected ? specialty : 'All';
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: const Color(0xFF6A4C93),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Switch(
                value: _isOnlineOnly,
                onChanged: (value) {
                  setState(() {
                    _isOnlineOnly = value;
                  });
                },
                activeColor: const Color(0xFF6A4C93),
              ),
              const SizedBox(width: 8),
              const Text('Show online doctors only'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor, {bool isMyDoctor = false}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.grey,
                    ),
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
                            if (doctor.isOnline)
                              Container(
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
                        Row(
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
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
                          '\$${doctor.consultationFee}',
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
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Implement chat functionality
                        _showSnackBar('Starting chat with ${doctor.name}');
                      },
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
                      onPressed: () {
                        // Implement appointment booking
                        _showSnackBar('Booking appointment with ${doctor.name}');
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Book'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6A4C93),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({String message = 'No doctors found'}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.psychology_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showDoctorDetails(Doctor doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey[300],
                      child: const Icon(
                        Icons.person,
                        size: 45,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            doctor.specialty,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 20, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('${doctor.rating} (${doctor.reviews} reviews)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'About',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  doctor.about,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCard(
                        'Experience',
                        '${doctor.experience} years',
                        Icons.work_outline,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildInfoCard(
                        'Fee',
                        '\$${doctor.consultationFee}',
                        Icons.attach_money,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackBar('Starting chat with ${doctor.name}');
                        },
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Start Chat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showSnackBar('Booking appointment with ${doctor.name}');
                        },
                        icon: const Icon(Icons.calendar_today),
                        label: const Text('Book Appointment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A4C93),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF6A4C93)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
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

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int reviews;
  final int experience;
  final bool isOnline;
  final int consultationFee;
  final String profileImage;
  final String about;
  final DateTime nextAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.isOnline,
    required this.consultationFee,
    required this.profileImage,
    required this.about,
    required this.nextAvailable,
  });
}